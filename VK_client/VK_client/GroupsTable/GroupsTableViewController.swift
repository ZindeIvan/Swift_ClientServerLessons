//
//  GroupsTableViewController.swift
//  VK_client
//
//  Created by Зинде Иван on 7/10/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

//Класс для отображения списка групп пользователя
class GroupsTableViewController : UITableViewController {
    //Элемент поиска
    @IBOutlet weak var groupsSearchBar : UISearchBar!
    
    //Свойство содержащее запрос групп пользователя
    private var groupsList : Results<Group>?  {
        let groups: Results<Group>? = realmService?.loadFromRealm()
        return groups?.sorted(byKeyPath: "id", ascending: true)
    }
    //Свойство содержащее запрос групп пользователя с фильтром
    private var groupsListSearchData : Results<Group>?  {
        guard let searchText = groupsSearchBar.text else {return groupsList}
        if searchText == "" {return groupsList}
        return groupsList?.filter("name CONTAINS[cd] %@", searchText)
    }
    //Свойство содержащее ссылку на класс работы с сетевыми запросами
    let networkService = NetworkService.shared
    //Свойство содержит ссылку на класс работы с Realm
    let realmService = RealmService.shared
    //Свойство - токен для наблюдения за изменениями данных в Realm
    private var groupsListSearchDataNotificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Укажем текущий класс делегат для строки поиска
        groupsSearchBar.delegate = self
        //Установим оповещения
        setNotifications()
        //Вызовем метод загрузки списка групп из сети
        loadGroupsFromNetwork()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Уберем текст в строке поиска
        groupsSearchBar.text = ""
        groupsSearchBar.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Возвращаем количество ячеек таблицы = количеству элементов массива groupsList
        return groupsListSearchData?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsTableCell") as? GroupsTableCell else { fatalError() }
        //Зададим надпись ячейки
        cell.groupNameLabel.text = groupsListSearchData?[indexPath.row].name
        //Установим иконку ячейки
        cell.groupIconView.sd_setImage(with: URL(string: (groupsListSearchData?[indexPath.item].photo50)!), placeholderImage: UIImage(named: "error"))
        return cell
    }
    
    //Метод обработки стандартных действий с ячейкой таблицы
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //Если действие - удаление
        if editingStyle == .delete {
            //Удалим группу из Realm
            guard let groups = groupsListSearchData?[indexPath.item] else { return }
            try? realmService?.delete(object: groups) 
        }
    }
    
    //Действие по добавлению группы
    @IBAction func addGroup (segue: UIStoryboardSegue){
       //Проверим идентификатор перехода
        if segue.identifier == "addGroup" {
            //Приведем источник перехода к классу всех доступных групп
            guard let allGroupsController = segue.source as? GroupsSearchTableViewController else {return}
            //Установим константу индекса выбранной строки
            if let indexPath = allGroupsController.tableView.indexPathForSelectedRow {
                //Создадим константу выбранной группы по выбранному индексу
                let group = allGroupsController.getGroupByIndex(index: indexPath.row)!
                //Проверим нет ли в списке групп пользователя выбранной группы
                if !(groupsList?.contains(group) ?? false){
                    try? realmService?.saveInRealm(object: group)
                }

            }
        }
    }
}

//Расширение для строки поиска
extension GroupsTableViewController : UISearchBarDelegate {
    
    //Метод обработки нажатия кнопки Отмена
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Уберем текст в строке поиска
        groupsSearchBar.text = ""
        groupsSearchBar.endEditing(true)
        //Перезагрузим данные таблицы
        tableView.reloadData()
    }
    
    //Метод обработки ввода текста в строку поиска
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Перезагрузим данные таблицы
        tableView.reloadData()
    }
}

//Расширение для работы с сетью
extension GroupsTableViewController {
    //Метод загрузки списка групп из сети в базу
    func loadGroupsFromNetwork(){
        networkService.loadGroups(token: Session.instance.token){ [weak self] result in
            switch result {
            case let .success(groups):
                DispatchQueue.main.async {
                    //Сохраним полученные данные в Realm
                    try? self?.realmService?.saveInRealm(objects: groups)
                }
            case let .failure(error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

//Методы работы с оповещениями Realm
extension GroupsTableViewController {
    
    //Метод установки оповещений
    func setNotifications(){
        //Установим наблюдателя для событий с данными в БД
        groupsListSearchDataNotificationToken = groupsListSearchData?.observe { [weak self] change in
            switch change {
            //Инициализация
            case .initial:
                #if DEBUG
                print("Initialized")
                #endif
            //Изменение
            case let .update(results, deletions: deletions, insertions: insertions, modifications: modifications):
                #if DEBUG
                print("""
                    New count: \(results.count)
                    Deletions: \(deletions)
                    Insertions: \(insertions)
                    Modifications: \(modifications)
                    """)
                #endif
                
                self?.tableView.beginUpdates()
                //Удаление элементов
                self?.tableView.deleteRows(at: deletions.map { IndexPath(item: $0, section: 0) }, with: .automatic)
                //Добавление элементов
                self?.tableView.insertRows(at: insertions.map { IndexPath(item: $0, section: 0) }, with: .automatic)
                //Обновление элементов
                self?.tableView.reloadRows(at: modifications.map { IndexPath(item: $0, section: 0) }, with: .automatic)
                self?.tableView.endUpdates()

            case let .error(error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
        
    }
    //Метод вызова оповещений об ошибках
    func showAlert(title: String? = nil,
                   message: String? = nil,
                   handler: ((UIAlertAction) -> ())? = nil,
                   completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: completion)
    }
}


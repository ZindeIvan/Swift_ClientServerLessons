//
//  GroupsSearchTableViewController.swift
//  VK_client
//
//  Created by Зинде Иван on 7/10/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Класс для отображения списка доступных групп пользователя
class GroupsSearchTableViewController : UITableViewController {
    //Элемент поиска
    @IBOutlet weak var groupsSearchBar : UISearchBar!
    
   //Свойство содержащее массив всех групп типа структура Group
   private var groupsList : [Group] = []

    //Свойство содержащее ссылку на класс работы с сетевыми запросами
    let networkService = NetworkService.shared
    
    //Метод возвращает Группу по индексу
    func getGroupByIndex (index : Int) -> Group? {
        guard index >= 0 && index < groupsList.count else {return nil}
        return groupsList[index]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Укажем текущий класс делегат для строки поиска
        groupsSearchBar.delegate = self
        //Вызовем метод поиска групп в сети
        searchGroupsInNetwork(searchText: "")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Возвращаем количество ячеек таблицы = количеству элементов массива groupsList
        return groupsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsSearchTableCell") as? GroupsSearchTableCell else { fatalError() }
        //Зададим надпись ячейки
        cell.groupSearchNameLabel.text = groupsList[indexPath.row].name
        //Установим иконку ячейки
        cell.groupSearchIconView.sd_setImage(with: URL(string: groupsList[indexPath.row].photo50), placeholderImage: UIImage(named: "error"))
        return cell
    }
}

//Расширение для строки поиска
extension GroupsSearchTableViewController : UISearchBarDelegate {
   
    //Метод обработки нажатия кнопки Отмена
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Уберем текст в строке поиска
        groupsSearchBar.text = ""
        groupsSearchBar.endEditing(true)
        //Перезагрузим данные таблицы
        searchGroupsInNetwork(searchText: "")
    }
    
    //Метод обработки ввода текста в строку поиска
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Заполним массив групп отобранных при помощи поиска при помощи замыкания
        if searchText.isEmpty {
            searchGroupsInNetwork(searchText: "")
        }
        else{
            searchGroupsInNetwork(searchText: searchText)
        }
    }
}

//Расширение для работы с сетью
extension GroupsSearchTableViewController {
    //Метод поиска групп в сети
    func searchGroupsInNetwork(searchText: String){
        networkService.groupsSearch(token: Session.instance.token, searchQuery: searchText){ [weak self] result in
            switch result {
            case let .success(groups):
                self?.groupsList = groups
                self?.tableView.reloadData()
            case let .failure(error):
                print(error)
            }
        }
    }
}

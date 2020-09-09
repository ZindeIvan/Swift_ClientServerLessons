//
//  FriendsTableViewController.swift
//  VK_client
//
//  Created by Зинде Иван on 7/8/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit
import RealmSwift

//Класс для отображения списка друзей пользователя
class FriendsViewController : BaseViewController{
    //Элемент таблицы
    @IBOutlet weak var friendsTableView: UITableView!{
        didSet{
            friendsTableView.dataSource = self
            friendsTableView.delegate = self
            friendsSearchBar.delegate = self
        }
    }
    //Элемент прокрутки
    @IBOutlet weak var friendsScroller : FriendsScrollerControlView!
    //Элемент поиска
    @IBOutlet weak var friendsSearchBar : UISearchBar!
    
    //Свойство содержащее запрос пользователей с фильтром
    private var friendsListSearchData : Results<User>? {
        let users: Results<User>? = realmService?.loadFromRealm().sorted(byKeyPath: "id", ascending: true)
        guard let searchText = friendsSearchBar.text else {return users}
        if searchText == "" {return users}
        return users?.filter("(firstName CONTAINS[cd] %@) || (lastName CONTAINS[cd] %@)", searchText, searchText)
    }
    //Массив содержащий отсортированных пользователей до изменения
    var sortedUsers : [UserPlaceholder] = []
    //Структура пользователя
    struct UserPlaceholder {
        var id : Int = 0
        var firstName : String = ""
        var lastName : String = ""
    }
    
    //Словарь секций
    var sections : [Character: [UserPlaceholder]] = [:]
    //Массив заголовков секций
    var sectionsTitles : [Character] = []
    
    //Текущий выбранный индекс таблицы
    var selectedIndexPath : IndexPath?
    
    //Свойство содержащее ссылку на класс работы с сетевыми запросами
    let networkService = NetworkService.shared
    
    //Свойство содержит ссылку на класс работы с Realm
    let realmService = RealmService.shared
    //Свойство - токен для наблюдения за изменениями данных в Realm
    private var filteredFriendsNotificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let friends = friendsListSearchData, friends.isEmpty {
            //Вызовем загрузку списка друзей из сети
            loadFriendsFromNetwork()
        }
        //Настроим секции
        setupSections()

        //Зарегистрируем Заголовок секций
        friendsTableView.register(UINib(nibName: "FriendsTableSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "sectionHeader")
        setNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFriendsFromNetwork()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        //Проверим идентификатор перехода
        if segue.identifier == "FriendsPhotoSegue" {
            //Если переход предназначен для открытия коллекции фото друга
            if let destination = segue.destination as? FriendsPhotoCollectionViewController {
                //Зададим идентификатор друга для коллекции которого вызван переход
                guard let friend = sections[sectionsTitles[selectedIndexPath!.section]]?[selectedIndexPath!.row] else {
                    fatalError()
                }
                //Получим индекс массива друзей по имени пользователя
                let index = friendsListSearchData?.firstIndex { (user) -> Bool in
                    if user.id == friend.id  {
                        return true
                    }
                    return false
                }
                destination.friendID = friendsListSearchData?[index!].id
            }
        }
    }
    
    //Метод настройки секций
    func setupSections (){
        sections = [:]
        //Обойдем массив пользователей
        guard let friendsArray = friendsListSearchData else {return}
        for friend in friendsArray {
            //Возьмем первую букву имени пользователя
            let firstLetter = friend.firstName.first!
            //Если в массиве секций уже есть секция с такой буквой
            //добавим в словарь имя пользователя
            if sections[firstLetter] != nil {
                sections[firstLetter]?.append(UserPlaceholder(id: friend.id, firstName: friend.firstName, lastName: friend.lastName))
            }
                //В противном случае добавим новый элемент словаря
            else {
                sections[firstLetter] = [UserPlaceholder(id: friend.id, firstName: friend.firstName, lastName: friend.lastName)]
            }
        }
        //Заполним массив заголовков секций
        sectionsTitles = Array(sections.keys).sorted()
        
        setupSortedUsers()
        setupFriendsScroller()
    }
    
    //Метод настройки элемента прокрутки
    func setupFriendsScroller (){
        //Вызовем метод заполнения массива букв элемента прокрутки
        friendsScroller.setLetters(letters: sectionsTitles)
        //Вызовем метод настройки элемента прокрутки
        friendsScroller.setupScrollerView()
        //Укажем текущий объект в качестве делегата
        friendsScroller.delegate = self
    }
    
}

extension FriendsViewController: UITableViewDataSource {    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Возвращаем количество элементов в секции
        return sections[sectionsTitles[section]]?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Возвращаем количество секций
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //Возвращаем заголовк секции
        guard let header = friendsTableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as? FriendsTableSectionHeaderView else { fatalError() }
        header.label.text = String(sectionsTitles[section])
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //Возвращаем высоту заголовка секции
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableCell") as? FriendsTableCell else { fatalError() }
        guard let friend = sections[sectionsTitles[indexPath.section]]?[indexPath.row] else {
            fatalError()
        }
        //Найдем индекс друга в списке друзей
        let index = friendsListSearchData?.firstIndex { (user) -> Bool in
            if user.id == friend.id {
                return true
            }
            return false
        }
        
        //Зададим надпись ячейки
        cell.friendNameLabel.text = getFullName(friendsListSearchData?[index!].firstName, friendsListSearchData?[index!].lastName)
        //Установим иконку ячейки
        if let photo = friendsListSearchData?[index!].photo50 {
            cell.iconImageView.sd_setImage(with: URL(string: photo), placeholderImage: UIImage(named: "error"))
        } else {
            cell.iconImageView.image = UIImage(named: "error")
        }
        //Установим настройки тени иконки аватарки друга
        cell.iconShadowView.configureLayer()
        //Установим настройки скругления иконки аватарки друга
        cell.iconImageView.configureLayer()
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        //Зададим переменную индекса выбранной ячейки
        selectedIndexPath = indexPath
        return indexPath
    }
    
    //Метод получения полного имени из имени и фамилии
    func getFullName (_ firstName : String?,_ lastName : String?) -> String{
        return (firstName ?? "") + " " + (lastName ?? "")
    }
    
}


extension FriendsViewController: UITableViewDelegate {
    
}

extension FriendsViewController : FriendsScrollerControlViewDelegate {
    //Метод прокрутки списка друзей
    func scrollFriends(letter: Character) {
        //Получим индекс секции по букве
        let index = sectionsTitles.firstIndex(of: letter)
        let indexPath = IndexPath(row: 0, section: index!)
        //Проматаем список до указанной позиции
        friendsTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}

//Расширение для строки поиска
extension FriendsViewController : UISearchBarDelegate{
    
    //Метод обработки нажатия кнопки Отмена
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Уберем текст в строке поиска
        friendsSearchBar.text = ""
        friendsSearchBar.endEditing(true)
        //Вызовем метод настройки секций
        setupSections()
        //Перезагрузим данные таблицы
        friendsTableView.reloadData()
        
    }
    
    //Метод обработки ввода текста в строку поиска
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Вызовем метод настройки секций
        setupSections()
        //Перезагрузим данные таблицы
        friendsTableView.reloadData()
    }
}

//Расширение для работы с сетью
extension FriendsViewController {
    //Метод загрузки списка друзей из сети
    func loadFriendsFromNetwork(){
        
        networkService.loadFriends(token: Session.instance.token){ [weak self] result in
            switch result {
            case let .success(users):
                DispatchQueue.main.async {
                    try? self?.realmService?.saveInRealm(objects: users)
                }
            case let .failure(error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
        
    }

}

//Методы работы с оповещениями Realm
extension FriendsViewController {

    //Метод установки оповещений
    func setNotifications(){
        //Установим наблюдателя для событий с данными в БД
        filteredFriendsNotificationToken = friendsListSearchData?.observe { [weak self] change in
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
                //Вычислим элементы для удаления
                let deletionsIndexes = self?.getIndexPathsFromIndexes(indexes: deletions)
                //Вычислим секции для удаления
                let sectionsToDelete = self?.getSectionsToDelete(indexes: deletionsIndexes ?? [IndexPath]())
                //Сохраним список секций до обновления
                let oldSectionsTitles = self?.sectionsTitles
                //Обновим секции
                self?.setupSections()
                //Вычислим индексы для вставки
                let insertionsIndexes = self?.getIndexPathsFromIndexes(indexes: insertions)
                //Вычислим секции для вставки
                let sectionsToInsert = self?.getSectionsToInsert(oldSectionsTitles: oldSectionsTitles ?? [Character]())
                
                self?.friendsTableView.beginUpdates()
                //Удаление
                self?.friendsTableView.deleteRows(at: deletionsIndexes ?? [IndexPath](), with: .automatic)
                self?.friendsTableView.deleteSections(sectionsToDelete ?? IndexSet(), with: .automatic)
                
                //Вставка
                self?.friendsTableView.insertRows(at: insertionsIndexes ?? [IndexPath](), with: .automatic)
                self?.friendsTableView.insertSections(sectionsToInsert ?? IndexSet(), with: .automatic)
                self?.friendsTableView.endUpdates()
                
                //Вычислим индексы для обновления
                let modifications = self?.getIndexPathsFromIndexes(indexes: modifications)
                self?.friendsTableView.beginUpdates()
                //Обновление
                self?.friendsTableView.reloadRows(at: modifications ?? [IndexPath](), with: .automatic)
                self?.friendsTableView.endUpdates()
                
            case let .error(error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
        
    }
    
    //Метод получения индексов для вставки
    func getIndexPathsFromIndexes(indexes: [Int]) -> [IndexPath]{
        var indexPaths : [IndexPath] = []
        for index in indexes {
            let friend = sortedUsers[index]
            guard let firstLetter = friend.firstName.first else {continue}
            guard let sectionIndex = sectionsTitles.firstIndex(of: firstLetter) else {continue}
            if let rowIndex = sections[sectionsTitles[sectionIndex]]?.firstIndex(where: { (user) -> Bool in
                if user.id == friend.id{
                    return true
                }
                return false
            }) {
                indexPaths.append(IndexPath(row: rowIndex, section: sectionIndex))}
            else {continue}
            
        }
        return indexPaths
    }
    
    //Метод получения секций для удаления
    func getSectionsToDelete(indexes: [IndexPath]) -> IndexSet{
        let indexSetToDelete = NSMutableIndexSet()
        var tempSections = sections
        for index in indexes {
            tempSections[sectionsTitles[index.section]]?.remove(at: index.row)
        }
        for section in tempSections {
            if section.value.count == 0 {
                indexSetToDelete.add(sectionsTitles.firstIndex(of: section.key)!)
            }
        }
        return indexSetToDelete as IndexSet
    }
    
    //Метод получения секция для вставки
    func getSectionsToInsert(oldSectionsTitles : [Character]) -> IndexSet{
        let indexSetToInsert = NSMutableIndexSet()
        for title in sectionsTitles {
            if oldSectionsTitles.firstIndex(of: title) == nil {
                indexSetToInsert.add(sectionsTitles.firstIndex(of: title)!)
            }
        }
        return indexSetToInsert as IndexSet
    }
    
    //Метод установки пользователей до изменения
    func setupSortedUsers(){
        if let friendsArray = friendsListSearchData {
            sortedUsers = friendsArray.map {
                UserPlaceholder(id: $0.id, firstName: $0.firstName, lastName: $0.lastName)
            }
        }
        
    }
}




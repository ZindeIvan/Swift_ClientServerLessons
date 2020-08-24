//
//  FriendsTableViewController.swift
//  VK_client
//
//  Created by Зинде Иван on 7/8/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Класс для отображения списка друзей пользователя
class FriendsViewController : UIViewController{
    //Элемент таблицы
    @IBOutlet weak var friendsTableView: UITableView!
    //Элемент прокрутки
    @IBOutlet weak var friendsScroller : FriendsScrollerControlView!
    //Элемент поиска
    @IBOutlet weak var friendsSearchBar : UISearchBar!
    
    //Свойство содержащее массив друзей пользователя типа структура User
    private var friendsList : [User] = []
    
    //Свойство содержащее массив друзей отобранных при помощи поиска
    private var friendsListSearchData : [User] = []
    
    //Словарь секций
    var sections : [Character: [String]] = [:]
    //Массив заголовков секций
    var sectionsTitles : [Character] = []
    
    //Текущий выбранный индекс таблицы
    var selectedIndexPath : IndexPath?
    
    //Свойство содержащее ссылку на класс работы с сетевыми запросами
    let networkService = NetworkService()
    
    //Свойство содержит ссылку на класс работы с Realm
    let realmService = RealmService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsSearchBar.delegate = self
        //Вызовем загрузку списка друзей из сети
        loadFriendsFromNetwork()
        //Загрузим список друзей из Realm
        loadUsersFromRealm()
//        В качестве массив друзей отобранных при помощи поиска укажем все элементы массива данных
        friendsListSearchData = friendsList
        //Настроим секции
        setupSections()
        //Настроим элемент прокрутки
        setupFriendsScroller()
        //Зарегистрируем Заголовок секций
        friendsTableView.register(UINib(nibName: "FriendsTableSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        friendsTableView.reloadData()
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
                guard let username = sections[sectionsTitles[selectedIndexPath!.section]]?[selectedIndexPath!.row] else {
                    fatalError()
                }
                //Получим индекс массива друзей по имени пользователя
                let index = friendsListSearchData.firstIndex { (user) -> Bool in
                    if user.userName == username {
                        return true
                    }
                    return false
                }
                destination.friendID = friendsListSearchData[index!].userID
            }
        }
    }
    
    //Метод настройки секций
    func setupSections (){
        sections = [:]
        //Обойдем массив пользователей
        for user in friendsListSearchData {
            //Возьмем первую букву имени пользователя
            let firstLetter = user.userName.first!
            //Если в массиве секций уже есть секция с такой буквой
            //добавим в словарь имя пользователя
            if sections[firstLetter] != nil {
                sections[firstLetter]?.append(user.userName)
            }
                //В противном случае добавим новый элемент словаря
            else {
                sections[firstLetter] = [user.userName]
            }
        }
        //Заполним массив заголовков секций
        sectionsTitles = Array(sections.keys).sorted()
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
        guard let username = sections[sectionsTitles[indexPath.section]]?[indexPath.row] else {
            fatalError()
        }
        //Найдем индекс друга в списке друзей
        let index = friendsListSearchData.firstIndex { (user) -> Bool in
            if user.userName == username {
                return true
            }
            return false
        }
        
        //Зададим надпись ячейки
        cell.friendNameLabel.text = friendsListSearchData[index!].userName
        //Установим иконку ячейки
        cell.iconImageView.sd_setImage(with: URL(string: friendsListSearchData[index!].userPhoto), placeholderImage: UIImage(named: "error"))
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
        //В качестве массив друзей отобранных при помощи поиска укажем все элементы массива данных
        friendsListSearchData = friendsList
        friendsSearchBar.endEditing(true)
        //Вызовем метод настройки секций
        setupSections()
        //Перезагрузим данные таблицы
        friendsTableView.reloadData()
        
    }
    
    //Метод обработки ввода текста в строку поиска
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Заполним массив друзей отобранных при помощи поиска при помощи замыкания
        friendsListSearchData = searchText.isEmpty ? friendsList : friendsList.filter {
            (user: User) -> Bool in
            return user.userName.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
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
                self?.realmService.saveInRealm(array: users)
                self?.loadUsersFromRealm()
                self?.loadFriendsAvatarImagesFromNetwork()
            case let .failure(error):
                print(error)
            }
        }
        
    }
    
    //Метод загрузки аватарок друзей
    func loadFriendsAvatarImagesFromNetwork(){
        
        for user in friendsList{
            networkService.loadPhotos(token: Session.instance.token, ownerID: Int(user.userID)!, albumID: .profile, photoCount: 1) { [weak self] result in
                switch result {
                case let .success(photo):
                    self?.realmService.saveInRealm(array:photo)
                    self?.loadUserAvatarsFromRealm()
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    
    
}

//Расширение для работы с Realm
extension FriendsViewController{
    
    //Метод загрузки списка друзей из Realm
    func loadUsersFromRealm(){
        
        guard let usersResults = realmService.loadFromRealm(type: UserItem.self, filter: nil) else {return}
        setFriendsFromUserItems(usersResults as! [UserItem])
        //Настроим секции
        setupSections()
        //Настроим элемент прокрутки
        setupFriendsScroller()
        
        loadUserAvatarsFromRealm()
        
        friendsTableView.reloadData()
    }
    
    func loadUserAvatarsFromRealm(){
        
        for friend in friendsListSearchData{
            let searchPredicate = NSPredicate(format: "ownerID == %i", Int(friend.userID) ?? 0)
            guard let photoResults = realmService.loadFromRealm(type: PhotoItem.self, filter: searchPredicate) else {return}
            let photos = photoResults as! [PhotoItem]
            if photos.count != 0 {
                friendsListSearchData[friendsListSearchData.firstIndex(of: friend)!].userPhoto = photos[0].photoSizeS
            }
        }
    }
    
    //Метод установки списка друзей
    func setFriendsFromUserItems(_ users : [UserItem]){
        friendsList = []
        for user in users {
            let newUser = User(userName: user.firstName + " " + user.lastName, userID: String(user.id), userPhoto: "")
            friendsList.append(newUser)
        }
        friendsList = friendsList.sorted()
        friendsListSearchData = friendsList
    }
    
}
    



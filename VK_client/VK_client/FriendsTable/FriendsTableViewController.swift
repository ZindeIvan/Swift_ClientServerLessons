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
class FriendsViewController : UIViewController{
    //Элемент таблицы
    @IBOutlet weak var friendsTableView: UITableView!
    //Элемент прокрутки
    @IBOutlet weak var friendsScroller : FriendsScrollerControlView!
    //Элемент поиска
    @IBOutlet weak var friendsSearchBar : UISearchBar!
    
    //Свойство содержащее запрос пользователей
    private var friendsList : Results<User>? {
        let users: Results<User>? = realmService?.loadFromRealm()
        return users?.sorted(byKeyPath: "id", ascending: true)
    }
    
    //Свойство содержащее запрос пользователей с фильтром
    private var friendsListSearchData : Results<User>? {
        guard let searchText = friendsSearchBar.text else {return friendsList}
        if searchText == "" {return friendsList}
        return friendsList?.filter("name CONTAINS[cd] %@", searchText)
    }
    
    //Словарь секций
    var sections : [Character: [String]] = [:]
    //Массив заголовков секций
    var sectionsTitles : [Character] = []
    
    //Текущий выбранный индекс таблицы
    var selectedIndexPath : IndexPath?
    
    //Свойство содержащее ссылку на класс работы с сетевыми запросами
    let networkService = NetworkService.shared
    
    //Свойство содержит ссылку на класс работы с Realm
    let realmService = RealmService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsSearchBar.delegate = self
        //Вызовем загрузку списка друзей из сети
        loadFriendsFromNetwork()
        loadFriendsAvatarImagesFromNetwork()
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
                let index = friendsListSearchData?.firstIndex { (user) -> Bool in
                    if getFullName(user.firstName, user.lastName)  == username {
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
        for name in friendsListSearchData?.map({getFullName($0.firstName,$0.lastName)}) ?? [String]() {
            //Возьмем первую букву имени пользователя
            let firstLetter = name.first!
            //Если в массиве секций уже есть секция с такой буквой
            //добавим в словарь имя пользователя
            if sections[firstLetter] != nil {
                sections[firstLetter]?.append(name)
            }
                //В противном случае добавим новый элемент словаря
            else {
                sections[firstLetter] = [name]
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
        let index = friendsListSearchData?.firstIndex { (user) -> Bool in
            if getFullName(user.firstName, user.lastName)  == username {
                return true
            }
            return false
        }
        
        //Зададим надпись ячейки
        cell.friendNameLabel.text = getFullName(friendsListSearchData?[index!].firstName, friendsListSearchData?[index!].lastName)
        //Установим иконку ячейки
        let photosResult: Results<Photo>? = realmService?.loadFromRealm().filter("ownerID == %i", friendsListSearchData?[index!].id ?? 0)
        if photosResult?.count ?? 0 > 0 {
            let photo = photosResult?[0].photoSizeS ?? ""
            if photo != "" {
                cell.iconImageView.sd_setImage(with: URL(string: photo), placeholderImage: UIImage(named: "error"))
            } else {
                cell.iconImageView.image = UIImage(named: "error")
            }
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
                    self?.friendsTableView.reloadData()
                }
                self?.loadFriendsAvatarImagesFromNetwork()
            case let .failure(error):
                print(error)
            }
        }
        
    }
    
    //Метод загрузки аватарок друзей
    func loadFriendsAvatarImagesFromNetwork(){
        
        for userID in friendsList?.map({$0.id}) ?? [Int]() {
            networkService.loadPhotos(token: Session.instance.token, ownerID: userID, albumID: .profile, photoCount: 1) { [weak self] result in
                switch result {
                case let .success(photo):
                    DispatchQueue.main.async {
                        try? self?.realmService?.saveInRealm(object: photo[0])
                        self?.friendsTableView.reloadData()
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
    



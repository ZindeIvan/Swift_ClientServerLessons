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
   private var groupsList : [Group] = [
    
        Group(groupName: "A.R.G.U.S.", groupID: "argus"),
        Group(groupName: "Birds of Prey", groupID: "birdsofprey"),
        Group(groupName: "Daily Planet", groupID: "dailyplanet"),
        Group(groupName: "Doom Patrol", groupID: "doompatrol"),
        Group(groupName: "Green Lanterns Corps", groupID: "greenlanternscorps"),
        Group(groupName: "Justice League", groupID: "justiceleague"),
        Group(groupName: "Justice Society of America", groupID: "justicesocietyofamerica"),
        Group(groupName: "S.T.A.R. Labs", groupID: "starlabs"),
        Group(groupName: "Suicide Squad", groupID: "suicidesquad"),
        Group(groupName: "Teen Titans", groupID: "teentitans"),
        Group(groupName: "Wayne Enterprises", groupID: "wayneenterprises")
        
    ]
    //Свойство содержащее массив групп отобранных при помощи поиска
    private var groupsListSearchData : [Group] = []
    
    //Метод возвращает Группу по индексу
    func getGroupByIndex (index : Int) -> Group? {
        guard index >= 0 && index < groupsListSearchData.count else {return nil}
        return groupsListSearchData[index]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Укажем текущий класс делегат для строки поиска
        groupsSearchBar.delegate = self
        //В качестве массив групп отобранных при помощи поиска укажем все элементы массива данных
        groupsListSearchData = groupsList
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Возвращаем количество ячеек таблицы = количеству элементов массива groupsList
        return groupsListSearchData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsSearchTableCell") as? GroupsSearchTableCell else { fatalError() }
        //Зададим надпись ячейки
        cell.groupSearchNameLabel.text = groupsListSearchData[indexPath.row].groupName
        //Установим иконку ячейки
        cell.groupSearchIconView.image = UIImage(named: groupsListSearchData[indexPath.row].groupID + "_icon")
        
        return cell
    }
}

//Расширение для строки поиска
extension GroupsSearchTableViewController : UISearchBarDelegate {
   
    //Метод обработки нажатия кнопки Отмена
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Уберем текст в строке поиска
        groupsSearchBar.text = ""
        //В качестве массив групп отобранных при помощи поиска укажем все элементы массива данных
        groupsListSearchData = groupsList
        groupsSearchBar.endEditing(true)
        //Перезагрузим данные таблицы
        tableView.reloadData()
    }
    
    //Метод обработки ввода текста в строку поиска
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Заполним массив групп отобранных при помощи поиска при помощи замыкания
        groupsListSearchData = searchText.isEmpty ? groupsList : groupsList.filter {
            (group: Group) -> Bool in
            return group.groupName.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        //Перезагрузим данные таблицы
        tableView.reloadData()
    }
}

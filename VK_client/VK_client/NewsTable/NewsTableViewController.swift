//
//  NewsTableViewController.swift
//  VK_client
//
//  Created by Зинде Иван on 7/25/20.
//  Copyright © 2020 zindeivan. All rights reserved.
//

import UIKit

//Класс экрана новостей
class NewsTableViewController : UIViewController {

    //Таблица новостей
    @IBOutlet weak var newsTableView : UITableView!
    
    //Массив новостей
    private var newsList : [News] = [
    
        News(newsID: "news1", newsWatchedCount: 1321, likeCount: 32, newsOwner: "Daly planet", newsDate:  "12.05.2020", newsText: "The object, known as Comet, was discovered by an instrument floating in space and it is falling towards the Earth. As it gets closer, the comet should be visible in the Southern Hemisphere just before sunrise, without any equipment."),
        News(newsID: "news2", newsWatchedCount: 200, likeCount: 88, newsOwner: "Justice Society of America", newsDate:  "15.04.2020", newsText: "Justice Society of America held anual veteran meeting"),
        News(newsID: "news3", newsWatchedCount: 5820, likeCount: 588, newsOwner: "Teen titans", newsDate:  "10.02.2020", newsText: "Teen titans are looking for new talants. You can send your C.V. to tt@wayneenterprises.com")
    
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsTableView.dataSource = self
        newsTableView.delegate = self
        //Зарегистрируем ячейку таблицы
        newsTableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        newsTableView.rowHeight = UITableView.automaticDimension
        
    }
    
}

extension NewsTableViewController : UITableViewDataSource, UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Возвращаем количество строк таблицы
        newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as? NewsCell else { fatalError() }
        //Установим автора
        cell.newsOwner.text = newsList[indexPath.row].newsOwner
        //Установим текст новости
        cell.newsText.text = newsList[indexPath.row].newsText
        //Установим дату новости
        cell.newsDate.text = newsList[indexPath.row].newsDate
        //Установим количество просмотров
        cell.watchedCountLabel.text = String(newsList[indexPath.row].newsWatchedCount)
        //Установим надписьлайков
        cell.likeLabel.text = String(newsList[indexPath.row].likeCount)
        //Установим иконку новости
        cell.newsIconView.image = UIImage(named: newsList[indexPath.row].newsID + "_icon")
        //Установим картинку новости
        cell.newsImage.image = UIImage(named: newsList[indexPath.row].newsID + "_image")
        //Установим количество лайков
        cell.likeCount = newsList[indexPath.row].likeCount
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 615
    }

    
}


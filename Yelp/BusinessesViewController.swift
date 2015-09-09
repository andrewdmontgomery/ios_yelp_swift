//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate {

    var businesses: [Business]!
        
    var categories: [String]?
    var sort: Int?
    var radius: Int?
    var deals: Bool?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        // Set some reasonable defaults
        sort = 0
        radius = 100

        performSearch()
//        Business.searchWithTerm(searchBar.text, completion: { (businesses: [Business]!, error: NSError!) -> Void in
//            self.businesses = businesses
//            self.tableView.reloadData()
//            
//            for business in businesses {
//                println(business.name!)
//                println(business.address!)
//            }
//        })
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performSearch(){
        var searchText = ""
        if let searchBar = navigationItem.titleView as? UISearchBar {
            searchText = searchBar.text
        }
        
        println("SEARCH:")
        println("searchText: \(searchText)")
        println("sort: \(YelpSortMode(rawValue: sort!))")
        println("categories: \(categories)")
        println("deals: \(deals)")
        println("radius: \(radius!))")
        
        Business.searchWithTerm(searchText, sort: YelpSortMode(rawValue: sort!), categories: categories, deals: deals, radius: radius!) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }

    }
    
    // MARK: - UITableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
    }

    // MARK: - filtersViewControllerDelegate
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        categories = filters["categories"] as? [String]
        sort = filters["sort"] as? Int
        radius = filters["radius"] as? Int
        deals = filters["deals"] as? Bool
        
        var searchText = ""
        
        if let searchBar = navigationItem.titleView as? UISearchBar {
            searchText = searchBar.text
        }
        
        performSearch()
        
    }
    
    // MARK: - UISearchControllerDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        println("searchBarTextDidChange")
        // Only perform a search when the (x) is pressed.
        // Otherwise, wait for searchBarSearchButtonClicked(seachBar: UISearchBar) to be called manually
        if count(searchText) == 0 {
            performSearch()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        println("searchBarSearchButtonClicked")
        let searchText = searchBar.text
        searchBar.endEditing(true)
        performSearch()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        let searchText = searchBar.text
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            searchBar.endEditing(true)
        })
        performSearch()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

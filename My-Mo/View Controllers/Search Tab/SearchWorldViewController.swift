//
//  SearchWorldViewController.swift
//  My-Mo
//
//  Created by iDeveloper on 11/14/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON
import MBProgressHUD

class SearchWorldViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SearchWorldUserTBCellDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var view_Navigation: UIView!
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var view_Title: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    @IBOutlet weak var view_Input: UIView!
    @IBOutlet weak var lbl_Numbers: UILabel!
    @IBOutlet weak var lbl_Country: UILabel!
    @IBOutlet weak var lbl_City: UILabel!
    @IBOutlet weak var btn_Country: UIButton!
    @IBOutlet weak var btn_City: UIButton!
    
    @IBOutlet weak var view_Table: UIView!
    @IBOutlet weak var tbl_List: UITableView!

    @IBOutlet weak var view_Button: UIView!
    @IBOutlet weak var btn_Search: UIView!
    
    @IBOutlet weak var view_Picker: UIView!
    @IBOutlet weak var picker_CountryCity: UIPickerView!
    
    
//    var loadingNotification:MBProgressHUD? = nil
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var refresh_Flag: Int = 0
    
    var array_Search_Users: [Follow_User] = []
    var country: Country = Country()
    
    var isCountryCity: Int = 0
    var Country_Row: Int = -1
    var City_Row: Int = -1
    
    // MARK: - Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        let rect:CGRect = CGRect(x: 0, y: COMMON.HEIGHT(view: view_Main), width: COMMON.WIDTH(view: view_Main), height: COMMON.HEIGHT(view: view_Picker))
        self.view_Picker.frame = rect
        
        country.initCountries()
        country.initCities()
        
//        refreshControl.addTarget(self, action: #selector(refreshAllDatas), for: .valueChanged)
//        tbl_List.addSubview(refreshControl)
    }

    //MARK: - Buttons' Events
    @IBAction func click_btn_BAck(_ sender: AnyObject) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func click_btn_Search(_ sender: AnyObject) {
        loadSearchUsersFromServer()
    }
    
    @IBAction func click_btn_Country(_ sender: Any) {
        showPickerView()
        isCountryCity = 1
        picker_CountryCity.reloadAllComponents()
    }
    
    @IBAction func btn_City(_ sender: Any) {
        if (City_Row == -1){
            City_Row = 0
        }
        
        showPickerView()
        isCountryCity = 2
        picker_CountryCity.reloadAllComponents()
        picker_CountryCity.selectRow(0, inComponent: 0, animated: true)
    }
    
    @IBAction func click_btn_Done(_ sender: Any) {
        hidePickerView()
    }
    
    //MARK: - UITableView delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_Search_Users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SearchWorldUserTBCell = self.tbl_List.dequeueReusableCell(withIdentifier: "SearchMapCell")! as! SearchWorldUserTBCell
        cell.cellDelegate = self
        
        let user: Follow_User = array_Search_Users[indexPath.row]
        
        cell.img_Avatar.sd_setImage(with: URL(string: user.avatar), placeholderImage: UIImage(named: "Placeholder_Avatar.png"))
        cell.lbl_Name.text = user.username
        cell.lbl_Followers.text = String(user.followers) + "  followers"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func pressedLikesButton(sender: UIButton){
        print(sender.tag)
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    func showPickerView(){
        let rect:CGRect = CGRect(x: 0, y: COMMON.HEIGHT(view: view_Main) - COMMON.HEIGHT(view: view_Picker), width: COMMON.WIDTH(view: view_Main), height: COMMON.HEIGHT(view: view_Picker))
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view_Picker.frame = rect
        })
    }
    
    func hidePickerView(){
        let rect:CGRect = CGRect(x: 0, y: COMMON.HEIGHT(view: view_Main), width: COMMON.WIDTH(view: view_Main), height: COMMON.HEIGHT(view: view_Picker))
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view_Picker.frame = rect
        })
    }
    
    //MARK: - SearchWorldUserTBCellDelegate
    func select_btn_Follow(cell: SearchWorldUserTBCell) {
        let indexPath: IndexPath = self.tbl_List.indexPath(for: cell)!
        
        sendFriendRequest(index: indexPath.row)
    }
    
    //MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (isCountryCity == 1){
            return country.array_Coutries.count
        }else if (isCountryCity == 2){
            if (Country_Row == -1){
                return 0
            }
            
            let arr: [String] = country.array_Cities[Country_Row] as! [String]
            return arr.count
        }
        
        return 0
    }
    
    //MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (isCountryCity == 1){
            return country.array_Coutries[row]
        }else if (isCountryCity == 2){
            if (Country_Row == -1){
                return ""
            }
            
            let arr: [String] = country.array_Cities[Country_Row] as! [String]
            return arr[row]
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (isCountryCity == 1){
            if (Country_Row != row){
                lbl_City.text = "City"
                lbl_City.textColor = UIColor.lightGray
                City_Row = -1
            }
            
            Country_Row = row
            lbl_Country.text = country.array_Coutries[row]
            lbl_Country.textColor = UIColor.black
        }else if (isCountryCity == 2){
            if (Country_Row == -1){
                return
            }
            
            let arr: [String] = country.array_Cities[Country_Row] as! [String]
            City_Row = row
            lbl_City.text = arr[row]
            lbl_City.textColor = UIColor.black
        }
    }
    
    //MARK: - refreshAllDatas
    func refreshAllDatas(){
        refresh_Flag = 1
        
        //        txt_Search.text = ""
        loadSearchUsersFromServer()
    }

    // MARK: - API Calls
    func loadSearchUsersFromServer(){
        if (Country_Row == -1){
            COMMON.methodForAlert(titleString: kAppName, messageString: "Please select country", OKButton: kOkButton, CancelButton: "", viewController: self)
            return
        }
        
        if (City_Row == -1){
            COMMON.methodForAlert(titleString: kAppName, messageString: "Please select city", OKButton: kOkButton, CancelButton: "", viewController: self)
            return
        }
        
        if (refresh_Flag == 0){
//            loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
//            loadingNotification?.mode = MBProgressHUDMode.indeterminate
//            loadingNotification?.label.text = "Loading..."
        }
        
        let parameters = ["user_id": USER.id, "country": lbl_Country.text ?? "", "city": lbl_City.text ?? ""] as [String : Any]
        Alamofire.request(kApi_SearchTheWorld, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil) .responseJSON { response in
            
            if (self.refresh_Flag == 0){
//                self.loadingNotification?.hide(animated: true)
            }else{
                self.refreshControl.endRefreshing()
                self.refresh_Flag = 0
            }
            
            switch response.result {
            case .success(_):
                let jsonObject = JSON(response.result.value!)
                let status: String = jsonObject["status"].stringValue
                if (status == "success"){
                    self.fetchSearchUserDataFromJSON(json: jsonObject["response"])
                    self.lbl_Numbers.text = String(self.array_Search_Users.count) + " mo's found"
                }else{
                    self.array_Search_Users = []
                    
                    self.tbl_List.reloadData()
                    self.lbl_Numbers.text = "0 mo's found"
                    //                    COMMON.methodForAlert(titleString: kAppName, messageString: "Login Failed", OKButton: kOkButton, CancelButton: "", viewController: self)
                }
                break
            case .failure(let error):
                self.lbl_Numbers.text = "0 mo's found"
                print(error)
                COMMON.methodForAlert(titleString: kAppName, messageString: kNetworksNotAvailvle, OKButton: kOkButton, CancelButton: "", viewController: self)
                break
            }
            
        }
    }
    
    func fetchSearchUserDataFromJSON(json: SwiftyJSON.JSON){
        array_Search_Users = []
        
        for i in (0..<json.count) {
            let follow_user = Follow_User()
            
            follow_user.initFollowUserDataWithJSON(json: json[i])
            array_Search_Users.append(follow_user)
        }
        
        //sort
        for i in (0..<array_Search_Users.count-1){
            var user: Follow_User = array_Search_Users[i]
            for j in (i..<array_Search_Users.count){
                let user_compare: Follow_User = array_Search_Users[j]
                
                if (user.username.lowercased().compare(user_compare.username.lowercased()) == .orderedAscending){
                    
                }else if (user.username.lowercased().compare(user_compare.username.lowercased()) == .orderedDescending){
                    array_Search_Users.remove(at: i)
                    array_Search_Users.insert(user_compare, at: i)
                    
                    array_Search_Users.remove(at: j)
                    array_Search_Users.insert(user, at: j)
                    
                    user = user_compare
                }
                
            }
        }
        
        tbl_List.reloadData()
    }
    
    func sendFriendRequest(index: Int){
        let user: Follow_User = array_Search_Users[index]
        
//        loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
//        loadingNotification?.mode = MBProgressHUDMode.indeterminate
//        loadingNotification?.label.text = "Loading..."
        
        let parameters = ["user_id": USER.id, "followee": user.id]
        Alamofire.request(KApi_JoinFriends, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil) .responseJSON { response in
            
//            self.loadingNotification?.hide(animated: true)
            
            switch response.result {
            case .success(_):
                let jsonObject = JSON(response.result.value!)
                let status: String = jsonObject["status"].stringValue
                if (status == "success"){
                    
                    self.array_Search_Users.remove(at: index)
                    
                    self.tbl_List.reloadData()
                }else{
                    COMMON.methodForAlert(titleString: kAppName, messageString: jsonObject["message"].stringValue, OKButton: kOkButton, CancelButton: "", viewController: self)
                }
                break
            case .failure(let error):
                print(error)
                COMMON.methodForAlert(titleString: kAppName, messageString: kNetworksNotAvailvle, OKButton: kOkButton, CancelButton: "", viewController: self)
                break
            }
            
        }
        
    }

}

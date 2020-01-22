//
//  DashBoardVC.swift
//  CutsomProgrammaticMenu
//
//  Created by Sherif  Wagih on 8/31/19.
//  Copyright © 2019 Sherif  Wagih. All rights reserved.
//

import UIKit
import ProgressHUD
class DashboardVC:BaseMenuVC {
    var isDoneLoadingDate = false;
    let flowLayout = UICollectionViewFlowLayout()
    
    lazy var  collectionView:UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        navigationController?.navigationBar.isHidden = true
        dashboardOpenerView.isUserInteractionEnabled = false
        adjustNavigationControllers()
        if Authenticate(animated: false)
        {
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(userDataDidChange), name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
        
        fetchData()
    }
    @objc func userDataDidChange()
    {
        fetchData()
    }

    var empStatistics : [TeamStatistics] = [TeamStatistics]()
    
    fileprivate func fetchData()
    {
        if NewUser.getLocallySavedUser()?.role == "Manager"
        {
            let dispatchGroup:DispatchGroup = DispatchGroup()

            let date = Date()
            
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            ProgressHUD.show("Loading Data")

            var finalURL1 = Utility.getFinalURL(methodName: "GetTeamAttendSummary")
            finalURL1.append("?fromDate=\(month)%2F\(day)%2F\(year)&toDate=\(month)%2F\(day)%2F\(year)")
            
            let header = ["Authorization":"Bearer \(NewUser.getLocallySavedUser()?.token ?? "")","Content-Type":"application/json; charset=utf-8"]


            dispatchGroup.enter()

            Service.shared.fetchGenericJSONData(urlString: finalURL1, parameters: nil, header: header) { (result:Array<TeamStatistics>?, err:Error?) in
                dispatchGroup.leave()
                
                //if error code 401 that means the token is invalid and the current user should be logged out for all methods
                
                if err != nil
                {
                    print(err!)
                }
                else
                {
                    if let res = result
                    {
                        self.empStatistics = res
                    }
                }
                ProgressHUD.dismiss();
            }
            dispatchGroup.enter()
            
            //POST /api/Mobile/GetRequests
            
            let finalURL2 = Utility.getFinalURL(methodName: "GetRequests")
            
            Service.shared.fetchGenericJSONData(urlString: finalURL2, parameters: nil, header: header) { (result:Array<TeamStatistics>?, err:Error?) in
                dispatchGroup.leave()
                if err != nil
                {
                    print(err!)
                }
                else
                {
                    if let res = result
                    {
                        self.empStatistics = res
                    }
                }
                ProgressHUD.dismiss();
            }
            
            dispatchGroup.notify(queue: .main){
                self.isDoneLoadingDate = true
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
            }

        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}
extension DashboardVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if NewUser.getLocallySavedUser()?.role  == "Manager" && isDoneLoadingDate
        {
            return 5
        }
        else if NewUser.getLocallySavedUser()?.role  != "Manager" && !isDoneLoadingDate

        {
            return 1
        }
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if NewUser.getLocallySavedUser()?.role  == "Manager" 
        {
            switch indexPath.item {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "circularPercentageCell", for: indexPath) as! CircularPercentageRowCell
                cell.backgroundColor = .dashboardGray
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentRequestsCell", for: indexPath) as! RecentRequestsCell
                cell.backgroundColor = .dashboardGray//UIColor(white: 0.95, alpha: 1)
                return cell
            case 3:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upComingVacationCell", for: indexPath) as! UpComingVacationCell
                cell.backgroundColor = .dashboardGray//.lightGray//UIColor(white: 0.95, alpha: 1)
                return cell
            case 4:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listOfEmployeesCell", for: indexPath) as! ListOfEmployeesCell
                cell.backgroundColor = .white//UIColor(white: 0.95, alpha: 1)
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listOfEmployeesCell", for: indexPath)
                cell.backgroundColor = .green
                return cell
            }
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upComingVacationCell", for: indexPath) as! UpComingVacationCell
            cell.backgroundColor = .dashboardGray//.lightGray//UIColor(white: 0.95, alpha: 1)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    fileprivate func setupCollectionView()
    {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DashBoardHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerID")
        collectionView.register(CircularPercentageRowCell.self, forCellWithReuseIdentifier: "circularPercentageCell")
        collectionView.register(RecentRequestsCell.self, forCellWithReuseIdentifier: "recentRequestsCell")
        collectionView.register(UpComingVacationCell.self, forCellWithReuseIdentifier: "upComingVacationCell")
        collectionView.register(ListOfEmployeesCell.self, forCellWithReuseIdentifier: "listOfEmployeesCell")
        view.addSubview(collectionView)
        collectionView.fillSuperView()
        view.insertSubview(collectionView, belowSubview: darkFillView)
        collectionView.backgroundColor = .white
        collectionView.bounces = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if NewUser.getLocallySavedUser()?.role  == "Manager"
        {
            return .init(width: view.frame.width, height: 424)
        }
        else
        {
            return .init(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as! DashBoardHeader
        if self.empStatistics.count > 0
        {
            header.appHeaderHorizontalController.empstatistics = self.empStatistics
            header.appHeaderHorizontalController.collectionView.reloadData()
        }
        header.backgroundColor = UIColor.dashboardGray
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if NewUser.getLocallySavedUser()?.role  == "Manager"
        {
            switch indexPath.row {
            case 0:
                return .init(width: view.frame.width, height: 220)
            case 1:
                return .init(width: view.frame.width, height: 320)
            case 2:
                return .init(width: 0, height: 0)
            case 3:
                return .init(width: view.frame.width, height:380)
            case 4:
                return .init(width: view.frame.width, height: 373)
            default:
                return .init(width: view.frame.width, height: 400)
            }
        }
        else
        {
            return .init(width: view.frame.width, height:380)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

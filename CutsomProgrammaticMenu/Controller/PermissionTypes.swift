//
//  PermissionTypes.swift
//  CutsomProgrammaticMenu
//
//  Created by Sherif  Wagih on 11/24/19.
//  Copyright © 2019 Sherif  Wagih. All rights reserved.
//

import UIKit
import ProgressHUD
class PermissionTypesVC:BaseMenuVC
{
    let collectionView:UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return cv
    }()
    
    let requestTypesHeader:UILabel = {
        let label = UILabel()
        label.text = "Select Request Type"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .headerLabelColor
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleView(title: "Select PermissionType", comparedTo: darkFillView)
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .permissionBGColor
        print(NewUser.getLocallySavedUser()?.token)
        setupCollectionView()
        getReuestTypes()
    }
    var requestTypes:[RequestType] = [RequestType]();
    private func getReuestTypes()
    {
        ProgressHUD.show("Loading Request Types")
        var finalURL = Utility.getFinalURL(methodName: "GetRequestTypes")
        
        let header = ["Authorization":"Bearer \(NewUser.getLocallySavedUser()?.token ?? "")","Content-Type":"application/json; charset=utf-8"]
        finalURL = finalURL + "?isEng=true"
        
        print(finalURL)
        
        Service.shared.fetchGenericJSONData(urlString: finalURL, parameters: nil, header: header) { (result:Array<RequestType>?, err:Error?) in
            ProgressHUD.dismiss()
            if err != nil
            {
                ProgressHUD.showError(err!.localizedDescription)
            }
            else
            {
                if let res = result
                {
                    self.requestTypes = res
                    self.collectionView.reloadData()
                }
            }
        }
    }
    private func setupCollectionView()
    {
        view.insertSubview(collectionView, belowSubview: darkFillView)
        
        collectionView.anchorToView(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 80, left: 0, bottom: 0, right: 0))
        
        addSubview(requestTypesHeader)
        
        requestTypesHeader.anchorToView(top: nil, leading: view.leadingAnchor, bottom: collectionView.topAnchor,padding: .init(top: 0, left: 15, bottom: 5, right: 0))
        
        collectionView.backgroundColor = .permissionBGColor
        
        collectionView.delegate = self;
        
        collectionView.dataSource = self;
        
        collectionView.register(PermissionTypeCell.self, forCellWithReuseIdentifier: "permissiontype")
    }
    
}
extension PermissionTypesVC:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requestTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "permissiontype", for: indexPath) as! PermissionTypeCell
        cell.permissionTypeLabel.text = requestTypes[indexPath.row].desc
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 60)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(PermissionVC(), animated: true)
    }
}

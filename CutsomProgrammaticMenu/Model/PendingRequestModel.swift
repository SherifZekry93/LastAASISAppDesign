//
//  PendingRequestModel.swift
//  CutsomProgrammaticMenu
//
//  Created by Sherif  Wagih on 1/21/20.
//  Copyright © 2020 Sherif  Wagih. All rights reserved.
//

import Foundation
struct PendingRequestModel:Codable
{
    let totalRecords: Int
    let records: [EmpDetails]

}
struct EmpDetails:Codable {
    let empId: Int
    let fileNumber: String
    let name: String
    let requestDate: String
    let requestDesc: String
    let requestTypeId: Int
    let statusId: Int
    let requestId: Int
    let requestDetailId: Int
    let allowApprove: Bool
}

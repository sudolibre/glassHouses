//
//  Environment.swift
//  Videos
//
//  Created by Florian Kugler on 10-10-2016.
//  Copyright © 2016 Chris Eidhof. All rights reserved.
//

import Foundation

enum State: String, CustomStringConvertible {
    case AL, AK, AZ, AR, CA, CO, CT, DE, FL, GA, HI, ID, IL, IN, IA, KS, KY, LA, ME, MD, MA, MI, MN, MS, MO, MT, NE, NV, NH, NJ, NM, NY, NC, ND, OH, OK, OR, PA, RI, SC, SD, TN, TX, UT, VT, VA, WA, WV, WI, WY
    var description: String {
        return self.rawValue
    }
}

struct Environment {
    var baseURL = "https://openstates.org/api/v1/"
    var state: State!
    static var current = Environment()
}

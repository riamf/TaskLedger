//
//  TaskTypeButtonLabel.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 08/10/2025.
//
import SwiftUI

struct TaskTypeButtonLabel: View {
    let systemImageName: String
    let title: String
    var body: some View {
        VStack {
            Image(systemName: systemImageName).tint(.black)
            Text(title).tint(.black).font(Font.system(.caption))
        }
    }
}


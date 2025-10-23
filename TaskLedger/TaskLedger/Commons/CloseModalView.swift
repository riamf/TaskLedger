//
//  CloseModalView.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 20/10/2025.
//
import SwiftUI

struct CloseModalView: View {
    
    private var dismiss: DismissAction
    
    init(dismiss: DismissAction) {
        self.dismiss = dismiss
    }
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image("close").tint(.black)
                        Text("Cancel").foregroundStyle(.black)
                    }
                }
                Spacer()
            }
        }
    }
}

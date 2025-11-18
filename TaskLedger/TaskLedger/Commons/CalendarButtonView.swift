import SwiftUI

struct CalendarButtonView: View {
    @Binding var showCalendarView: Bool
    
    var body: some View {
        Button {
            showCalendarView.toggle()
        } label: {
            Image(systemName: "calendar")
                .tint(.black)
        }
    }
}

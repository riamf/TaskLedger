import SwiftUI

struct TimeInputView: View {
    @Binding var inputTaskName: String
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Task name:").padding(.leading, 16).frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $inputTaskName, prompt: Text("Enter task name"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
            Text("Enter time spent:")
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: .spacingSmall) {
                VStack{
                    Text("Hours: ")
                    TextField("Hours", value: $hours, format: .number, prompt: Text("Hours")).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                VStack {
                    Text("Minutes: ")
                    TextField("Minues", value: $minutes, format: .number, prompt: Text("Minutes")).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                VStack {
                    Text("Seconds: ")
                    TextField("Seconds", value: $seconds, format: .number, prompt: Text("Seconds")).textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }.padding(.horizontal, .bigSpacing)
        }
    }
}

#Preview {
    @Previewable @State var inputTaskName: String = ""
    @Previewable @State var hours: Int = 0
    @Previewable @State var minutes: Int = 0
    @Previewable @State var seconds: Int = 0
    TimeInputView(
        inputTaskName: $inputTaskName,
        hours: $hours,
        minutes: $minutes,
        seconds: $seconds
    )
}

import SwiftUI

struct TimeInputView: View {
    @Binding var inputTaskName: String
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text("task_name_label").padding(.leading, 16).frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $inputTaskName, prompt: Text("enter_task_name_prompt"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
            Text("enter_time_spent_label")
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: .spacingSmall) {
                VStack{
                    Text("time_hours_label")
                    TextField("time_hours_prompt", value: $hours, format: .number, prompt: Text("time_hours_prompt")).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                VStack {
                    Text("time_minutes_label")
                    TextField("time_minutes_prompt", value: $minutes, format: .number, prompt: Text("time_minutes_prompt")).textFieldStyle(RoundedBorderTextFieldStyle())
                }
                VStack {
                    Text("time_seconds_label")
                    TextField("time_seconds_prompt", value: $seconds, format: .number, prompt: Text("time_seconds_prompt")).textFieldStyle(RoundedBorderTextFieldStyle())
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

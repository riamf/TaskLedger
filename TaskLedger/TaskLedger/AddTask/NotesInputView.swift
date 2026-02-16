import SwiftUI

struct NotesInputView: View {
    @Binding var notes: String
    
    var body: some View {
        VStack(spacing: .spacingSmall) {
            HStack {
                Text("Task Notes:")
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, .spacing)
            
            TextField("",
                      text: $notes,
                      prompt: Text("Enter notes here..."),
                      axis: .vertical)
            .textFieldStyle(.roundedBorder)
            .lineLimit(3, reservesSpace: true)
            .padding(.horizontal, .spacing)
        }
    }
}

#Preview {
    NotesInputView(notes: .constant(""))
}

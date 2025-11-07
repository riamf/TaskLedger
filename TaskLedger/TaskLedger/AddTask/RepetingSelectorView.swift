import SwiftUI

struct RepetingSelectorView<T: CustomCaseIterable>: View {
    @State var repeating: T
    
    var body: some View {
        HStack {
            ForEach(T.allValuesSamples, id: \.name) { pattern in
                CheckButton(
                    title: pattern.name,
                    isChecked: repeating.name == pattern.name,
                    value: pattern,
                    action: { selectedValue in
                        self.repeating = selectedValue as! T
                    }
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var pattern: RepeatingPattern = .monthly(day: 10)
    RepetingSelectorView(repeating: pattern)
}

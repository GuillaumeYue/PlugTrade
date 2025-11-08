import SwiftUI

// 1) 先定义 Modifier（internal 即可）
struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(12)
                        .padding(.bottom, 24)
                        .accessibilityLabel(Text(message))
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.2), value: isPresented)
            }
        }
    }
}

// 2) 再写全局扩展（一定要在 #if DEBUG 外面，且在文件顶层）
extension View {
    func toast(isPresented: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastModifier(isPresented: isPresented, message: message))
    }
}

#if DEBUG
// 3) 预览（可留可删）
struct Toast_Previews: PreviewProvider {
    static var previews: some View {
        DemoToast()
            .previewLayout(.sizeThatFits)
    }
}

private struct DemoToast: View {
    @State private var show = true
    var body: some View {
        VStack { Button("Toggle") { withAnimation { show.toggle() } } }
            .toast(isPresented: $show, message: "已发送交换提议")
            .padding()
            .frame(width: 300, height: 200)
    }
}
#endif

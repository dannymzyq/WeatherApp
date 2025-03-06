import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var animationName: String

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView()
        animationView.loopMode = .loop
        // Asignamos la animación inicial
        animationView.animation = LottieAnimation.named(animationName)
        animationView.play()
        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        // Reasignamos la animación en cada actualización
        uiView.animation = LottieAnimation.named(animationName)
        uiView.play()
    }
}

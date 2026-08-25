
// MARK: - UIGlassEffect Fallback Shim
class UIGlassEffect: UIVisualEffect {
    enum Style { case regular }
    var isInteractive: Bool = false
    init(style: Style = .regular) { super.init() }
    required init?(coder: NSCoder) { super.init(coder: coder) }
}

import SwiftUI
import UIKit

// Directly adapted from GlobalRefresh-PiP's UIKit glass path.
// Reference: https://github.com/Yoroin/GlobalRefresh-PiP
struct ReferenceGlassMaterial: UIViewRepresentable {
    let cornerRadius: CGFloat
    let isInteractive: Bool

    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)
        container.backgroundColor = .clear

        if #available(iOS 26.0, *) {
            let glassEffect = UIGlassEffect(style: .regular)
            glassEffect.isInteractive = isInteractive

            let glassView = UIVisualEffectView(effect: glassEffect)
            glassView.layer.cornerRadius = cornerRadius
            glassView.layer.cornerCurve = .continuous
            glassView.clipsToBounds = true
            glassView.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(glassView)
            NSLayoutConstraint.activate([
                glassView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                glassView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                glassView.topAnchor.constraint(equalTo: container.topAnchor),
                glassView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        } else {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            blurView.contentView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.42)
            blurView.layer.cornerRadius = cornerRadius
            blurView.layer.cornerCurve = .continuous
            blurView.clipsToBounds = true
            blurView.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(blurView)
            NSLayoutConstraint.activate([
                blurView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                blurView.topAnchor.constraint(equalTo: container.topAnchor),
                blurView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.cornerCurve = .continuous
    }
}

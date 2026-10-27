import SwiftUI

/// Clear, honest step-by-step guide for enabling single-app lockdown on iPhone 7 Plus.
/// Technical Reality: No standard third-party iOS app has permission to programmatically lock the system into another app.
/// Apple provides Guided Access as a built-in accessibility feature.
public struct GuidedAccessGuideView: View {
    @Environment(\.presentationMode) var presentationMode

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                GlacierTheme.glacierGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        overviewCard
                        stepsList
                        doneButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Guided Access Setup")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private var overviewCard: some View {
        GlacierCard(borderColor: GlacierTheme.seasonalPine.opacity(0.4)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(GlacierTheme.seasonalPine)
                        .font(.system(size: 20))

                    Text("True Hardware Single-App Lock")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)
                }

                Text("Apple's sandbox strictly prohibits apps from forcibly confining you to another app. However, Apple's built-in 'Guided Access' feature allows you to lock your iPhone 7 Plus into any game with a simple triple-click of the physical Home Button.")
                    .font(.system(size: 12))
                    .foregroundColor(GlacierTheme.silverSlate)
                    .lineSpacing(2)
            }
        }
    }

    private var stepsList: some View {
        VStack(spacing: 12) {
            stepCard(
                number: "1",
                title: "Open iOS Settings",
                instruction: "Launch the native Settings.app on your iPhone 7 Plus."
            )
            stepCard(
                number: "2",
                title: "Navigate to Accessibility",
                instruction: "Scroll down and tap 'Accessibility', then scroll to the General section and select 'Guided Access'."
            )
            stepCard(
                number: "3",
                title: "Toggle Guided Access On",
                instruction: "Turn the switch ON. Tap 'Passcode Settings' to set a passcode (or use Touch ID) so only you can exit."
            )
            stepCard(
                number: "4",
                title: "Enable Accessibility Shortcut",
                instruction: "Ensure 'Accessibility Shortcut' is turned ON. This binds the activation trigger to triple-clicking your Home Button."
            )
            stepCard(
                number: "5",
                title: "Activate Inside Your Game",
                instruction: "Open your favorite game (e.g. Mobile Legends or PUBG), triple-click the physical Home Button, and tap 'Start' in the top-right corner. Swiping and notifications are now completely locked into the game!"
            )
        }
    }

    private func stepCard(number: String, title: String, instruction: String) -> some View {
        GlacierCard {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(GlacierTheme.iceBlue.opacity(0.2))
                        .frame(width: 32, height: 32)

                    Text(number)
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(GlacierTheme.frostCyan)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Text(instruction)
                        .font(.system(size: 12))
                        .foregroundColor(GlacierTheme.silverSlate)
                        .lineSpacing(2)
                }

                Spacer()
            }
        }
    }

    private var doneButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Got It")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(GlacierTheme.heroButtonGradient)
                .cornerRadius(12)
        }
        .padding(.top, 4)
    }
}

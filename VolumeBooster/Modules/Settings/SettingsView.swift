import SwiftUI

struct SettingsView: View {
    @State private var isIconCoverOn = false
    
    private let URL_PRIVACY_POLICY = "https://google.com"
    private let URL_TERMS_USE = "https://google.com"
    private let URL_SHARE = "https://google.com"
    private let URL_RATE_US = "https://google.com"
    private let URL_CONTACT_US = "https://google.com"
    
    var body: some View {
        ZStack {
            Color(hex: "#0F0F0F").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) { // Spacing between main sections
                Form {
                    Group {
                        Section {
                            Button(action: {
                                      
                                       print("premium button tapped!")
                                 
                            }) {
                                       HStack {
                                           Image("ic_premium")
                                               .foregroundColor(.white)
                                           Text("Premium")
                                               .foregroundColor(.white)
                                               .fontWeight(.semibold)
                                       }
                                       .frame( maxWidth: .infinity, maxHeight: .infinity)
                                       .padding()
                                       .background(
                                                      LinearGradient(
                                                          gradient: Gradient(colors: [Color(hex: "#84DB77"), Color(hex: "#3A842E")]),
                                                          startPoint: .top,
                                                          endPoint: .bottom
                                                      )
                                                  )
                                       .cornerRadius(10)
                                   }.frame( maxWidth: .infinity, maxHeight: 30)
                                
                            
                        }
                        // First Group: Icon Cover
                        Section {
                            HStack {
                                Image("ic_cover")
                                    .foregroundColor(.blue)
                                Text("Icon Cover")
                                    .foregroundColor(.white)
                                Spacer()
                                Toggle("", isOn: $isIconCoverOn)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(Color(hex: "#202020"))
                            .cornerRadius(10)
                        }
                        
                        // Second Group: Privacy Policy and Terms of Use
                        Section {
                            
                            VStack(spacing: 0) {
                                settingsRow(icon: "ic_privacy_policy", text: "Privacy Policy", color: .green)
                                Divider().background(Color.gray.opacity(0.3))
                                settingsRow(icon: "ic_terms", text: "Terms of Use", color: .green)
                            }
                            .onTapGesture {
                                openURL(urlString: URL_PRIVACY_POLICY)
                            }
                            .background(Color(hex: "#202020"))
                            .cornerRadius(10)
                        }
                        
                        // Third Group: Share, Rate Us, and Contact Us
                        Section {
                            VStack(spacing: 0) {
                                settingsRow(icon: "ic_share", text: "Share", color: .orange).onTapGesture {
                                    openURL(urlString: URL_SHARE)
                                }
                                Divider().background(Color.gray.opacity(0.3))
                                settingsRow(icon: "ic_rate_us", text: "Rate Us", color: .yellow).onTapGesture {
                                        openURL(urlString: URL_RATE_US)
                                    }
                                Divider().background(Color.gray.opacity(0.3))
                                settingsRow(icon: "ic_contact_us", text: "Contact Us", color: .purple).onTapGesture {
                                    openURL(urlString: URL_CONTACT_US)
                                }
                            }
                          
                            .background(Color(hex: "#202020"))
                            .cornerRadius(10)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                .background(Color(hex: "#0F0F0F"))
                .scrollContentBackground(.hidden)
            }
            .padding(.vertical, 10)
        }
    }
    
    func settingsRow(icon: String, text: String, color: Color) -> some View {
        HStack {
            Image(icon)
                .foregroundColor(color)
            Text(text)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex:"#3E9B2F"))
        }
        .padding()
    }
    
    func openURL(urlString: String) {
           if let url = URL(string: urlString) {
               UIApplication.shared.open(url)
           }
       }
}

#Preview {
    SettingsView()
}

import SwiftUI
import SceneKit

/// Entrypoint in the app
struct MainView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
                
                VStack(alignment: .center) {
                    VStack(alignment: .center) {
                        
                        Text("CubeOS")
                            .font(.system(size: 70, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .padding(.bottom, 50)
                            .opacity(1.0)
                        Text("136 Apps")
                            .font(.system(size: 25, weight: .semibold, design: .default))
                            .foregroundColor(Color(red:197/255, green:1, blue:248/255))
                            .padding(.bottom, 30)
                            .opacity(1.0)
                        Text("4 Widgets")
                            .font(.system(size: 25, weight: .semibold, design: .default))
                            .foregroundColor(Color(red:197/255, green:1, blue:248/255))
                            .padding(.bottom, 30)
                            .opacity(1.0)
                        Text("4 Banners")
                            .font(.system(size: 25, weight: .semibold, design: .default))
                            .foregroundColor(Color(red:197/255, green:1, blue:248/255))
                            .padding(.bottom, 40)
                            .opacity(1.0)
                        Text("One")
                            .font(.system(size: 50, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .opacity(1.0)
                        Text("Page")
                            .font(.system(size: 50, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .padding(.bottom, 30)
                            .opacity(1.0)
                        
                        
                    }                    
                    Spacer()
                    
                    NavigationLink (
                        destination: AboutView().navigationBarBackButtonHidden(true),
                        label: {
                            
                            Text("Get Started")
                                .foregroundColor(.white)
                                .padding(.horizontal, 25)
                                .padding(.vertical, 10)
                                .background(Color.blue) 
                                .cornerRadius(50)
                            
                        })
                    
                    .padding(.bottom, 100)
                }
                .padding(.top, 100)
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

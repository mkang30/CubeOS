import SwiftUI
import SceneKit

/// Contains information about the CubeOS and instructions
struct AboutView: View {
  var body: some View {
    GeometryReader { proxy in
      NavigationView {
        ZStack {
          Color(red: 0.2, green:0.2, blue: 0.2)
          VStack(alignment: .center) {
            
            VStack(alignment: .center) {
              
              BlockView(h1: "What is", h2: "CubeOS",
                        b: "A design prototype for a single-page iOS Home Screen.", color: .cyan)
              BlockView(h1: "Why", h2: "CubeOS",
                        b: "To utilize the space more efficiently. Also I grew tired of the traditional page-centered design of iOS. Time for a little change.", color: .mint)
              BlockView(h1: "How", h2: "CubeOS",
                        b: "Simply drag the rows and columns to flip them, similar to manipulating a Rubik's cube. The interface consists of three different cubes in the center and two rectangular prisms (that you can flip as well), one each at the top and bottom.", color: .blue)
              BlockView(h1: "Who", h2: "MSK",
                        b: "Hi, I am Min Seong! Currently a college student, I identify myself as an innovator. I love working on creative projects that can shift and challenge perspectives. Thank you so much for your interest!", color: .purple)
              
            }
            Spacer()
            
            NavigationLink (
              destination: HomeScreenView(scene: CubeScene(width: proxy.size.width, height: proxy.size.height), camera: HomeScreenView.createCameraNode(width: proxy.size.width, height: proxy.size.height))
                .navigationBarBackButtonHidden(true),
              label: {
                
                Text("CubeOS")
                  .foregroundColor(.white)
                  .padding(.horizontal, 25)
                  .padding(.vertical, 10)
                  .background(Color.blue)
                  .cornerRadius(50)
                
              })
            
            .padding(.bottom, 100)
            
          }
          .padding(.top, 100)
          
          
        }.ignoresSafeArea()
      }
      .navigationViewStyle(.stack)
      .navigationBarBackButtonHidden(true)
      
    }
  }
}

struct AboutView_Previews: PreviewProvider {
  static var previews: some View {
    AboutView()
  }
}

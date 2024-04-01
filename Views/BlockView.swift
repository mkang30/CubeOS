import SwiftUI

/// Custom reusable text view for AboutView
struct BlockView: View {

    var h1: String
    var h2: String
    var b: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(h1)
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundColor(.white)
            Text(h2)
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(color)
                .padding(.top, 5)
            Text(b)
                .foregroundColor(.white)
                .frame(width: 300, alignment: .leading)
                .clipped()
                .font(.system(size: 15, weight: .medium, design: .default))
                .padding(.top, 5)
        }.padding(.bottom, 15)
    }
}
    



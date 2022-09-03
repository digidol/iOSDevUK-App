//
//  SwiftUIView.swift
//  SwiftUIInView
//
//  Created by Neil Taylor on 03/09/2022.
//

import SwiftUI

struct AboutAppView: View {
    
    @ObservedObject private var viewModel = AboutAppModel()
    
    var appDataClient: AppDataClient?
    
    func emailString() -> String {
        let destination = "mailto:nst@aber.ac.uk"
        if let versionInfo = viewModel.data,
           let encoded = versionInfo.text.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            return "\(destination)?subject=iOSDevUK%20App%20\(encoded)"
        }
        else {
            return destination
        }
    }
    
    var body: some View {
            ScrollView {
                VStack(spacing: 5.0) {
                    Image("DefaultImage")
                        .resizable()
                        .frame(width: 160, height: 160, alignment: .center)
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(20.0)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 12.0, trailing: 0))
                        
                    if let data = viewModel.data {
                        Text("\(data.text)")
                    }
                    else {
                        Text("Error accessing build information")
                    }
                    
                    Text("""
    The app has been prepared with coffee, Swift and a liberal sprinkling of autolayout. App data curated and wrangled by Chris.

    Thanks to [@John_Gilbey](https://twitter.com/John_Gilbey) for his picture of conference attendees that is used in this app.

    Some of the artwork uses icons from [@glyphish](https://twitter.com/glyphish) (www.glyphish.com).

    Other images by Neil & Chris.
    """
    )
                        .multilineTextAlignment(.center)
                        .padding()
                    Link("Email the developers", destination: URL(string: emailString())!)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10.0, trailing: 0))
                    Text("[Contact @digidol](https://twitter.com/digidol/)")
                    
                }
            }
        }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}

struct ModelData {
    
    var text: String
}

class AboutAppModel : ObservableObject {
    
    @Published var data : ModelData? = nil
    
    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let buildDateTime = formatter.date(from: String(Bundle.main.buildVersionNumber.prefix(10)))
        
        formatter.dateFormat = "MMMM yyyy"
        let text = "Version: \(Bundle.main.releaseVersionNumber) • \(formatter.string(from: buildDateTime!))"
        
        self.data = ModelData(text: text)
    }
}

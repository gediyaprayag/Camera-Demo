//
//  ContentView.swift
//  Camera-Demo
//
//  Created by Prayag Gediya on 08/07/23.
//

import SwiftUI

struct ContentView: View {
    @State private var openCameraPicker = false
    @State private var images: [UIImage] = []
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    let imageSize = (UIScreen.main.bounds.width - 4) / 3

    var body: some View {
        NavigationView {
            VStack {
                if images.isEmpty {
                    Spacer()
                    Text("No images selected.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                } else {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 2) {
                        ForEach(images.indices, id: \.self) {
                            Image(uiImage: images[$0])
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle("Images")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        openCameraPicker = true
                    } label: {
                        Image(systemName: "camera.fill")
                    }
                }
            })
            .sheet(isPresented: $openCameraPicker) {
                CameraPickerView { image in
                    guard let image else { return }
                    images.append(image)
                }
                .ignoresSafeArea()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

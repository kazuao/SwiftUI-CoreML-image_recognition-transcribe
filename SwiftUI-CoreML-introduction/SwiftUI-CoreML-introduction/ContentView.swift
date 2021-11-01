//
//  ContentView.swift
//  SwiftUI-CoreML-introduction
//
//  Created by kazunori.aoki on 2021/11/01.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    
    // なんの画像か
    @State var classificationLabel = ""
    
    var body: some View {
        VStack {
            Text(classificationLabel)
                .padding()
                .font(.title)
            
            Image("cat")
                .resizable()
                .frame(width: 300, height: 200)
            
            Button(action: {
                classifyImage(image: UIImage(named: "cat")!)
            }) {
                Text("この画像はなんの画像？")
                    .padding()
            }
        }
    }
}

extension ContentView {

    /// リクエストの作成
    func createClassificationRequest() -> VNCoreMLRequest {
        do {
            // モデル設定
            let configure = MLModelConfiguration()

            // モデル
            let model = try VNCoreMLModel(for: Resnet50(configuration: configure).model)


            let request = VNCoreMLRequest(model: model) { request, error in
                performClassification(request: request)
            }

            return request

        } catch {
            fatalError("modelが読み込めません")
        }
    }

    /// 画像分類の処理
    func performClassification(request: VNRequest) {

        guard let results = request.results else { return }

        let classification = results as! [VNClassificationObservation]

        // 結果をラベルに反映
        classificationLabel = classification[0].identifier
    }

    /// 実際に画像を分類する
    func classifyImage(image: UIImage) {
        // 入力されたUIImageをCIImageに変換
        guard let ciImage = CIImage(image: image) else {
            fatalError("CIImageに変換できません")
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)

        // リクエストの作成
        let classificationRequest = createClassificationRequest()

        // handlerの実行
        do {
            try handler.perform([classificationRequest])
        } catch {
            fatalError("画像の分類に失敗しました")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

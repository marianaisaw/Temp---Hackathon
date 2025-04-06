//
//  ContentView.swift
//  redax
//
//  Created by Mariana Isabel Gonzalez Reyes on 4/5/25.
//

//
//  ContentView.swift
//  redax
//
//  Created by Mariana Isabel Gonzalez Reyes on 4/5/25.
//

//
//  ContentView.swift
//  redax
//
//  Created by Mariana Isabel Gonzalez Reyes on 4/5/25.
//

import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct ContentView: View {
    
    @State private var showPicker = false
    @State private var selectedPDF: URL?
    @State private var context: String = ""

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("REDAX")
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .font(.largeTitle)

                    Image(systemName: "highlighter")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                }

                Text("A faster way to redax documents")
                    .font(.title2)
                    .fontDesign(.rounded)
            }

            HStack {
                Text("Advanced AI-powered software solution that automates the redaction of sensitive information in documents, ensuring full compliance with the Freedom of Information Act (FOIA) and related privacy regulations...")
            }
            .padding(20)

            if let pdf = selectedPDF {
                PDFKitView(url: pdf)
                    .frame(maxHeight: 400)
                    .padding()
            } else {
                VStack {
                    Spacer()
                    Button(action: {
                        showPicker = true
                    }) {
                        Image(systemName: "square.and.arrow.up.circle")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                            .font(.system(size: 250))
                    }
                    .padding(20)

                    if let pdf = selectedPDF {
                        Text("Selected: \(pdf.lastPathComponent)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .sheet(isPresented: $showPicker) {
                    DocumentPicker { urls in
                        selectedPDF = urls.first
                        showPicker = false
                    }
                }

                Spacer(minLength: 250)
            }

            Divider()
            Spacer()

            Text("Input the context of the document: ")
                .font(.title3)
                .fontDesign(.rounded)
                .padding(20)

            HStack {
                TextField("Message...", text: self.$context)
                    .font(.system(size: 20))
                    .padding(.vertical, 20)
            }
            .padding()
            .background(Color.indigo.opacity(0.05))
            .frame(height: 80)
            .cornerRadius(10)
            .fontDesign(.rounded)

            Divider()
            Spacer(minLength: 20)

            Button("Upload PDF File and Document Context") {
                uploadPDFAndContext()
            }
            .font(.title3)
            .padding(30)
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(10)

            Spacer(minLength: 80)
        }
    }

    // MARK: - Upload Function
    func uploadPDFAndContext() {
        guard let pdfURL = selectedPDF else { return }

        let url = URL(string: "http://127.0.0.1:8000/upload")! // Change to your backend URL

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Context part
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"context\"\r\n\r\n")
        body.append("\(context)\r\n")

        // PDF part
        if let pdfData = try? Data(contentsOf: pdfURL) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(pdfURL.lastPathComponent)\"\r\n")
            body.append("Content-Type: application/pdf\r\n\r\n")
            body.append(pdfData)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Upload response: \(httpResponse.statusCode)")
            }

            if let data = data {
                print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }.resume()
    }
}

// MARK: - PDF Viewer

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    var onDocumentsPicked: ([URL]) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(onDocumentsPicked: onDocumentsPicked)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onDocumentsPicked: ([URL]) -> Void

        init(onDocumentsPicked: @escaping ([URL]) -> Void) {
            self.onDocumentsPicked = onDocumentsPicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onDocumentsPicked(urls)
        }
    }
}

// MARK: - Data Extension for Multipart

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

#Preview {
    ContentView()
}




/*
 
 NOTES:
 
//context of the case

//ATTORNEY CLIENT PRIVILEDGE
//WORK PRODUCT

//GREEN I FSURE
//YELLOW
//LEARNING WHULE YOU ARE DOING IT
//YES OR NO BUTTON
 
 Jurisdiction rules that we want to build
*/

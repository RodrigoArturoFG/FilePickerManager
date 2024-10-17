//
//  DocumentPicker.swift
//  FilePicker
//
//  Created by Fernández González Rodrigo Arturo on 15/10/24.
//

import SwiftUI

/** Custom UIViewControllerRepresentable de UIDocumentPickerViewController - iOS 14+
 
Nos permite mostrarle al usuario los archivos de su dispositivo (solo archivos .pdf), para seleccionar el archivo deseado.
 El archivo es devuelto en formato **Data** para su posterior manipulación en la aplicación.
 
 **No se requiere solicitar al usuario el acceso al directorio del dipositivo.**
 De acuerdo con Apple: *When the user selects a directory in the document picker, the system gives your app permission to access that directory and all of its contents. The document picker returns a security-scoped URL for the directory.*
 
 https://developer.apple.com/documentation/uikit/view_controllers/providing_access_to_directories
   
   
**Uso (Declaration con variables Bindings)**
 ````
 DocumentPicker(isFilePickerPresented: Binding<Bool>, documentData: Binding<Data?>, presentDocumentAlert: Binding<Bool>)
 ````
 
**Proceso**
 1. Presentar el Picker -> isFilePickerPresented = true
 2. El usuario selecciona el documento PDF deseado
 3. Se trata el documento para convertirlo en Data
 4. Se devuelve la Data ->  documentData = Data
 6. Si ocurre un error se devuelve un true ->  presentDocumentAlert = true
 5. Despedir la hoja presentada
 
 *Ejemplo de uso en SwuiftUI*
 
 ````
 // Declarar variables antes del body
 @State private var isFilePickerPresented: Bool = false
 @State private var documentData: Data?
 @State private var documentSize: String?
 
 @State private var presentDocumentAlert: Bool = false
 @State private var messageDocumentAlert = "Ocurrio un error al cargar el documento"
 
 // Dentro del body
 Button("Seleccionar Documentos") {
     isFilePickerPresented.toggle()
 }.sheet(isPresented: $isFilePickerPresented) {
     // Presentar el Document Picker
     DocumentPicker(isFilePickerPresented: $isFilePickerPresented, documentData: $documentData, presentDocumentAlert: $presentDocumentAlert)
 }.onChange(of: documentData) { _ in
     // Se obtuvo la Data del documento seleccionado
     // Manejo de la respuesta
     let bcf = ByteCountFormatter()
     bcf.allowedUnits = [.useKB] // optional: restricts the units to MB only
     bcf.countStyle = .file
     self.documentSize = bcf.string(fromByteCount: Int64(documentData!.count))
 }.alert(isPresented: $presentDocumentAlert) {
     // Ocurrió un error al seleccionar un documento
     Alert(
         title: Text("Error Documento"),
         message: Text(messageDocumentAlert),
         dismissButton: .default(Text("Ok"), action: {
             presentDocumentAlert.toggle()
         })
     )
 }.padding()
 
 // Text View - para mostrar el tamaño del archivo seleccionado
 Text("Data: " + (self.documentSize ?? "0 KB"))
     .foregroundColor(.secondary)
     .padding()
 ````
 
 - Version: 1.0
 
 */
public struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var isFilePickerPresented: Bool
    @Binding var documentData: Data?
    //@Binding var filePath: URL?
    
    @Binding var presentDocumentAlert: Bool
    
    public init(isFilePickerPresented: Binding<Bool>, documentData: Binding<Data?>, presentDocumentAlert: Binding<Bool>) {
        self._isFilePickerPresented = isFilePickerPresented
        self._documentData = documentData
        self._presentDocumentAlert = presentDocumentAlert
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        controller.allowsMultipleSelection = false
        controller.delegate = context.coordinator
        return controller
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Use a Coordinator to act as your UIDocumentPickerDelegate
    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        private let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let filePath: URL?
            
            parent.isFilePickerPresented = false
            filePath = urls[0]
            //print(urls[0].absoluteString)
                        
            if (filePath != nil) {
                // Start accessing the content's security-scoped URL.
                guard filePath!.startAccessingSecurityScopedResource() else {
                    // Handle the failure here.
                    // Ocurrió un error al acceder al documento
                    self.parent.presentDocumentAlert = true
                    return
                }
                
                do {
                    let fileData = try Data(contentsOf: filePath! as URL)
                    print(fileData)
                    self.parent.documentData = fileData
                    // Make sure you release the security-scoped resource when you finish.
                    filePath!.stopAccessingSecurityScopedResource()
                } catch {
                    // Ocurrió un error al convertir el documento en Data
                    self.parent.presentDocumentAlert = true
                    // Make sure you release the security-scoped resource when you finish.
                    filePath!.stopAccessingSecurityScopedResource()
                }
            }
        }
    }
}

//
//  PhotoPicker.swift
//  FilePicker
//
//  Created by Fernández González Rodrigo Arturo on 15/10/24.
//

import SwiftUI
import PhotosUI


/** Custom UIViewControllerRepresentable de PHPickerViewController - iOS 14+

Nos permite que el usuario seleccione la fotografía deseada  (solo fotografías no videos).
 La imagen es devuelta en formato UIImage para su posterior uso en la aplicación.
 
 **No se requiere solicitar al usuario el acceso a su biblioteca de fotografías.**
 De acuerdo con Apple: *It has privacy built in by default. It doesn't need direct access to the photos library to show the picker and the picker won't prompt for access on behalf of the app.*
 
 https://developer.apple.com/videos/play/wwdc2020/10652/
   
   
**Uso (Declaration con variables Bindings)**
 ````
 PhotoPicker(isPhotoPickerPresented: Binding<Bool>, image: Binding<UIImage?>, presentImageAlert: Binding<Bool>)
 ````
 
**Proceso**
 1. Presentar el Picker -> isPhotoPickerPresented = true
 2. El usuario selecciona la fotografía deseada
 3. Se trata el objeto para convertirlo en UIImage
 4. Se devuelve la UIImage -> inputImage = UIImage
 6. Si ocurre un error se devuelve -> presentImageAlert = true
 5. Despedir la hoja presentada
 
 *Ejemplo de uso en SwuiftUI*
 
 ````
 // Declarar variables antes del body
 @State private var isPhotoPickerPresented: Bool = false
 @State private var inputImage: UIImage?

 @State private var presentImageAlert: Bool = false
 @State private var messageImageAlert = "Ocurrio un error al cargar la imagen"
 
 @State private var image = Image(systemName:"photo.on.rectangle.angled")
 
 // Dentro del body
 Button("Seleccionar Imagen") {
     isPhotoPickerPresented.toggle()
 }.sheet(isPresented: $isPhotoPickerPresented) {
     PhotoPicker(isPhotoPickerPresented: $isPhotoPickerPresented, image:$inputImage, presentImageAlert: $presentImageAlert)
 }.onChange(of: inputImage) { _ in
     presentImageAlert = false
     guard let inputImage = inputImage else { return }
     image = Image(uiImage: inputImage)
 }.alert(isPresented: $presentImageAlert) {
     Alert(
         title: Text("Error Imagen"),
         message: Text(messageImageAlert),
         dismissButton: .default(Text("Ok"), action: {
             presentImageAlert.toggle()
         })
     )
 }.padding()
 
 // Image View - Contenedor de la imágen seleccionada
 image.resizable()
     .scaledToFill()
     .frame(width: 107, height: 107)
     .padding()
 ````
 
 - Version: 1.0
 - Requires: PhotosUI
 
 */
public struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var isPhotoPickerPresented: Bool
    @Binding var image: UIImage?
    //@Binding var data: Data?
    
    @Binding var presentImageAlert: Bool
    
    /*
    public var selection = [String: PHPickerResult]()
    public var selectedAssetIdentifiers = [String]()
    public var selectedAssetIdentifierIterator: IndexingIterator<[String]>?
    public var currentAssetIdentifier: String?
    */
    
    public init(isPhotoPickerPresented: Binding<Bool>, image: Binding<UIImage?>, presentImageAlert: Binding<Bool>) {
        self._isPhotoPickerPresented = isPhotoPickerPresented
        self._image = image
        self._presentImageAlert = presentImageAlert
    }
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        configuration.preferredAssetRepresentationMode = .current
        // Set the preselected asset identifiers with the identifiers that the app tracks.
        // configuration.preselectedAssetIdentifiers = selectedAssetIdentifiers
        
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Se usa un Coordinator para actuar como el PHPickerViewControllerDelegate
    public class Coordinator: PHPickerViewControllerDelegate {
        
        private let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Una vez seleccionado un elemento hay que despedir la hoja presentada
            parent.isPhotoPickerPresented = false
            
            /*
            let existingSelection = self.parent.selection
            var newSelection = [String: PHPickerResult]()
            for result in results {
                let identifier = result.assetIdentifier!
                newSelection[identifier] = existingSelection[identifier] ?? result
            }
            */
            
            guard let provider = results.first?.itemProvider else {  return }
            
            DispatchQueue.main.async {
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, error in
                        if(error != nil){
                            self.parent.presentImageAlert = true
                            print(error?.localizedDescription as Any)
                        }else{
                            let image = image as? UIImage
                            self.parent.image = image
                            //self.parent.data = image?.jpegData(compressionQuality: 1)
                        }
                    }
                }
            }
        }
    }
}

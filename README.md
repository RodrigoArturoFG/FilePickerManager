# FilePickerManager

Swift Package Manager que permite al usuario seleccionar archivos (solo archivos .pdf) o fotografías (solo fotografías no videos) desde la aplicación.

# Implementación

Agregar paquete desde Xcode: File -> Add Packages... -> Agregar ruta del repositorio en la barra de busqueda -> Seleccionar Branch o version deseada.
  
Importar el paquete en el view container deseado

````
import FilePickerManager
 ````

## PhotoPicker

Custom UIViewControllerRepresentable de PHPickerViewController - iOS 14+

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
 }
 ````

## DocumentPicker

Custom UIViewControllerRepresentable de UIDocumentPickerViewController - iOS 14+
 
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
 }
 ````

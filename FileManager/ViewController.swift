import UIKit


class ViewController: UIViewController {

    private var tableView: UITableView!

    override func viewDidLoad() {

        super.viewDidLoad()

        title = "Documents"

        setupTableView()
        loadContent()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhotoButtonTapped))
    }


    private func setupTableView() {

        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
    }


    private func loadContent() {
        
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            content = files
            tableView.reloadData()
        } catch {
            print("Error loading content: \(error.localizedDescription)")
        }
    }


    @objc private func addPhotoButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }


    private func savePhoto(_ image: UIImage) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(documentsURL)
        let fileURL = documentsURL.appendingPathComponent("\(Date().timeIntervalSince1970).jpg")
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
                content.append(fileURL)
                tableView.reloadData()
            } catch {
                print("Error saving photo: \(error.localizedDescription)")
            }
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        content.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = content[indexPath.row].lastPathComponent
        return cell
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            deletePhoto(at: indexPath)
        }
    }


    private func deletePhoto(at indexPath: IndexPath) {

        let fileURL = content[indexPath.row]
        do {
            try FileManager.default.removeItem(at: fileURL)
            content.remove(at:indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Error deleting photo: \(error.localizedDescription)")
        }
    }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            savePhoto(image)
        }
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        picker.dismiss(animated: true, completion: nil)
    }
}

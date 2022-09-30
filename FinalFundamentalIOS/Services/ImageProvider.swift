import UIKit
import CoreData

class ImageProvider {
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "AccountsApp")
    container.loadPersistentStores {_, error in
      guard error == nil else {
        fatalError("unresolver\(error!)")
      }
    }
    container.viewContext.automaticallyMergesChangesFromParent = false
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.shouldDeleteInaccessibleFaults = true
    container.viewContext.undoManager = nil
    return container
  }()
  
  private func newTaskContext() -> NSManagedObjectContext {
    let taskContext = persistentContainer.newBackgroundContext()
    taskContext.undoManager = nil
    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    // Kelas ini nantinya akan mengembalikan nilai NSManagedObjectContext yang akan berjalan di dalam background
    return taskContext
  }
  
  func createImage(_ image: Data, completion: @escaping() -> Void) {
    let taskContext = newTaskContext()
    taskContext.performAndWait {
      if let entity = NSEntityDescription.entity(forEntityName: "Account", in: taskContext) {
        let account = NSManagedObject(entity: entity, insertInto: taskContext)
        account.setValue(image, forKeyPath: "image")
        do {
          try taskContext.save()
          completion()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
      }
    }
  }
  func getImage(completion: @escaping(_ accounts: AccountModel) -> Void) {
    let taskContext = newTaskContext()
    taskContext.perform {
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Account")
      fetchRequest.fetchLimit = 1
      do {
        if let result = try taskContext.fetch(fetchRequest).last {
          let Account = AccountModel(
            image: result.value(forKeyPath: "image") as? Data
          )
          completion(Account)
        }
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
  }
}

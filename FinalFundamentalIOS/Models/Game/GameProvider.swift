import UIKit
import CoreData

class GamesProvider {
  lazy var persistanceContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "GamesData")
    // swiftlint:disable function_parameter_count
    // swiftlint:disable void_return
    // swiftlint:disable unused_closure_parameter
    container.loadPersistentStores { (storeDescription, error) in
      guard error == nil else {
        print("Unresolved load persistenStore")
        return
      }
    }
    container.viewContext.automaticallyMergesChangesFromParent = false
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.shouldDeleteInaccessibleFaults = true
    container.viewContext.undoManager = nil
    
    return container
  }()
  
  private func newTaskContext() -> NSManagedObjectContext {
    let taskContext = persistanceContainer.newBackgroundContext()
    taskContext.undoManager = nil
    
    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return taskContext
  }
  
  func getAllGames(completion: @escaping(_ members: [GamesModel]) -> ()) {
    let taskContext = newTaskContext()
    taskContext.perform {
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Games")
      do {
        let results = try taskContext.fetch(fetchRequest)
        var games: [GamesModel] = []
        for result in results {
          let game = GamesModel(
            id: result.value(forKey: "gameId") as? Int32,
            title: result.value(forKey: "gameTitle") as? String,
            description: result.value(forKey: "gameDescription") as? String,
            dateReleased: result.value(forKey: "gameReleased") as? Date,
            backgroundImage: result.value(forKey: "gameBackgroundImage") as? String,
            website: result.value(forKey: "gameWebsite") as? String,
            rating: result.value(forKey: "gameRating") as? Double,
            selected: result.value(forKey: "gameSelected") as? Bool)
          games.append(game)
        }
        completion(games)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
  }
  
  func getGames(_ gameId: Int, completion: @escaping(_ members: GamesModel) -> ()) {
    let taskContext = newTaskContext()
    taskContext.perform {
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Games")
      fetchRequest.fetchLimit = 1
      fetchRequest.predicate = NSPredicate(format: "gameId == \(gameId)")
      do {
        if let result = try taskContext.fetch(fetchRequest).first {
          let game = GamesModel(id: result.value(forKey: "gameId") as? Int32,
                                title: result.value(forKey: "gameTitle") as? String,
                                description: result.value(forKey: "gameDescription") as? String,
                                dateReleased: result.value(forKey: "gameReleased") as? Date,
                                backgroundImage: result.value(forKey: "gameBackgroundImage") as? String,
                                website: result.value(forKey: "gameWebsite") as? String,
                                rating: result.value(forKey: "gameRating") as? Double,
                                selected: result.value(forKey: "gameSelected") as? Bool)
          completion(game)
        }
        
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
  }
  
  func addGames(_ gameId: Int32,
                _ gameSelected: Bool,
                _ gameDescription: String,
                _ gameReleased: Date,
                _ gameBackgroundImage: String,
                _ gameWebsite: String,
                _ gameRating: Double,
                _ gameTitle: String) {
    let taskContext = newTaskContext()
    taskContext.performAndWait {
      if let entity = NSEntityDescription.entity(forEntityName: "Games", in: taskContext) {
        let game = NSManagedObject(entity: entity, insertInto: taskContext)
        game.setValue(gameId, forKey: "gameId")
        game.setValue(gameSelected, forKey: "gameSelected")
        game.setValue(gameTitle, forKey: "gameTitle")
        game.setValue(gameDescription, forKey: "gameDescription")
        game.setValue(gameReleased, forKey: "gameReleased")
        game.setValue(gameBackgroundImage, forKey: "gameBackgroundImage")
        game.setValue(gameWebsite, forKey: "gameWebsite")
        game.setValue(gameRating, forKey: "gameRating")
        
        do {
          try taskContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
        
      }
    }
  }
  
  func deleteAllGames(completion: @escaping() -> ()) {
    let tasContext = newTaskContext()
    tasContext.perform {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Games")
      let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      batchDeleteRequest.resultType = .resultTypeCount
      if let batchDelegeteResult = try? tasContext.execute(batchDeleteRequest) as? NSBatchDeleteResult, batchDelegeteResult.result != nil {
        completion()
      }
    }
  }
  
  func deleteGamesById(_ gameId: Int32, completion: @escaping() -> ()) {
    let taskContext = newTaskContext()
    taskContext.perform {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Games")
      fetchRequest.fetchLimit = 1
      fetchRequest.predicate = NSPredicate(format: "gameId == \(gameId)")
      let batchDeleteReq = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      batchDeleteReq.resultType = .resultTypeCount
      if let batchDeleteRes = try? taskContext.execute(batchDeleteReq) as? NSBatchDeleteResult, batchDeleteRes.result != nil {
        completion()
      }
      
    }
  }
  
  func updateGame(_ gameId: Int32,
                  _ gameSelected: Bool,
                  _ gameDescription: String,
                  _ gameReleased: Date,
                  _ gameBackgroundImage: String,
                  _ gameWebsite: String,
                  _ gameRating: Double,
                  _ gameTitle: String, completion: @escaping() -> ()) {
    let taskContext = newTaskContext()
    taskContext.perform {
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Games")
      fetchRequest.fetchLimit = 1
      fetchRequest.predicate = NSPredicate(format: "gameId == \(gameId)")
      if let result = try? taskContext.fetch(fetchRequest), let games = result.first as? Games {
        games.setValue(gameTitle, forKey: "gameTitle")
        games.setValue(gameDescription, forKey: "gameDescription")
        games.setValue(gameReleased, forKey: "gameReleased")
        games.setValue(gameBackgroundImage, forKey: "gameBackgroundImage")
        games.setValue(gameWebsite, forKey: "gameWebsite")
        games.setValue(gameRating, forKey: "gameRating")
        do {
          try taskContext.save()
          completion()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
      }
      
    }
  }
}

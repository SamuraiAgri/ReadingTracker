// ファイル名: ReadingTracker/Models/PersistenceController.swift

import CoreData
// 以下を追加
import ReadingTracker // プロジェクト名をインポート

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ReadingTracker")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Core Dataストアのロードに失敗しました: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // プレビュー用のサンプルデータを作成
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // サンプルブックの作成
        let sampleBook1 = Book(context: viewContext)
        sampleBook1.id = UUID()
        sampleBook1.title = "人工知能の哲学"
        sampleBook1.author = "山田太郎"
        sampleBook1.coverImageName = "sample_book_1"
        sampleBook1.totalPages = 320
        sampleBook1.currentPage = 150
        sampleBook1.status = 1  // 読書中
        sampleBook1.startDate = Date().addingTimeInterval(-7 * 24 * 60 * 60)  // 1週間前
        sampleBook1.addedDate = Date().addingTimeInterval(-10 * 24 * 60 * 60)  // 10日前
        
        let sampleBook2 = Book(context: viewContext)
        sampleBook2.id = UUID()
        sampleBook2.title = "デザインの基本"
        sampleBook2.author = "佐藤花子"
        sampleBook2.coverImageName = "sample_book_2"
        sampleBook2.totalPages = 240
        sampleBook2.currentPage = 0
        sampleBook2.status = 0  // 未読
        sampleBook2.addedDate = Date().addingTimeInterval(-5 * 24 * 60 * 60)  // 5日前
        
        let sampleBook3 = Book(context: viewContext)
        sampleBook3.id = UUID()
        sampleBook3.title = "効率的な時間管理術"
        sampleBook3.author = "田中一郎"
        sampleBook3.coverImageName = "sample_book_3"
        sampleBook3.totalPages = 180
        sampleBook3.currentPage = 180
        sampleBook3.status = 2  // 読了
        sampleBook3.startDate = Date().addingTimeInterval(-30 * 24 * 60 * 60)  // 30日前
        sampleBook3.finishDate = Date().addingTimeInterval(-2 * 24 * 60 * 60)  // 2日前
        sampleBook3.addedDate = Date().addingTimeInterval(-32 * 24 * 60 * 60)  // 32日前
        
        // 読書セッションの作成
        let session1 = ReadingSession(context: viewContext)
        session1.id = UUID()
        session1.date = Date().addingTimeInterval(-3 * 24 * 60 * 60)  // 3日前
        session1.startPage = 100
        session1.endPage = 150
        session1.duration = 45  // 45分
        session1.book = sampleBook1
        
        let session2 = ReadingSession(context: viewContext)
        session2.id = UUID()
        session2.date = Date().addingTimeInterval(-1 * 24 * 60 * 60)  // 1日前
        session2.startPage = 120
        session2.endPage = 180
        session2.duration = 60  // 60分
        session2.book = sampleBook3
        
        // メモの作成
        let note1 = Note(context: viewContext)
        note1.id = UUID()
        note1.content = "人工知能の倫理的課題について興味深い視点が示されている"
        note1.pageNumber = 120
        note1.createdAt = Date().addingTimeInterval(-2 * 24 * 60 * 60)  // 2日前
        note1.book = sampleBook1
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("プレビューデータの保存に失敗しました: \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
}

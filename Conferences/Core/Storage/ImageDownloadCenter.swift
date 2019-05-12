//
//  ImageDownloadOperation.swift
//  JPEG Core
//
//  Created by Guilherme Rambo on 09/05/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import UIKit
import RealmSwift
import ConferencesCoreTV

typealias ImageDownloadCompletionBlock = (_ sourceURL: URL, _ original: UIImage?, _ thumbnail: UIImage?) -> Void

final class ImageDownloadCenter {

    static let shared: ImageDownloadCenter = ImageDownloadCenter()

    private let cacheProvider = ImageCacheProvider()
    private let queue = OperationQueue()

    func downloadImage(from url: URL, thumbnailHeight: CGFloat, thumbnailOnly: Bool = false, completion: @escaping ImageDownloadCompletionBlock) -> Operation? {
        if let cache = cacheProvider.cacheEntity(for: url) {
            var original: UIImage?

            if !thumbnailOnly {
                original = UIImage(data: cache.original)
            }

            let thumb = UIImage(data: cache.thumbnail)

//            original?.cacheMode = .never
//            thumb?.cacheMode = .never

            completion(url, original, thumb)

            return nil
        }


        if let activeOp = getActiveOperation(for: url) {
            activeOp.completionBlock = { [] in
                DispatchQueue.main.async {
                    if let cache = self.cacheProvider.cacheEntity(for: url) {
                        var original: UIImage?

                        if !thumbnailOnly {
                            original = UIImage(data: cache.original)
                        }

                        let thumb = UIImage(data: cache.thumbnail)

//                        original?.cacheMode = .never
//                        thumb?.cacheMode = .never
                        completion(url, original, thumb)
                    }
                }
            }

            return activeOp
        }

        let operation = ImageDownloadOperation(url: url, cache: cacheProvider, thumbnailHeight: thumbnailHeight)
        operation.imageCompletionHandler = completion

        queue.addOperation(operation)

        return operation
    }

    func hasActiveOperation(for url: URL) -> Bool {
        return queue.operations.contains { op in
            guard let op = op as? ImageDownloadOperation else { return false }

            return op.url == url && op.isExecuting && !op.isCancelled
        }
    }

    fileprivate func getActiveOperation(for url: URL) -> ImageDownloadOperation? {
        for op in queue.operations {
            guard let op = op as? ImageDownloadOperation else { return nil }

            if op.url == url {
                return op
            } else {
                return nil
            }
        }

        return nil
    }

}

final class ImageCacheEntity: Object {

    @objc dynamic var key: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var original: Data = Data()
    @objc dynamic var thumbnail: Data = Data()

    override class func primaryKey() -> String {
        return "key"
    }

}

private final class ImageCacheProvider {

    private var originalCaches: [URL: URL] = [:]
    private var thumbCaches: [URL: URL] = [:]

    private let upperLimit = 16 * 1024 * 1024

    private lazy var realm: Realm? = {
         return try? Realm()
    }()

    func cacheEntity(for url: URL) -> ImageCacheEntity? {
        return realm?.object(ofType: ImageCacheEntity.self, forPrimaryKey: url.absoluteString)
    }

    func cacheImage(for key: URL, original: Data?, thumbnail: Data?) {
        guard let original = original, let thumbnail = thumbnail else { return }

        guard original.count < upperLimit, thumbnail.count < upperLimit else { return }

        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                guard let bgRealm = try? Realm() else { return }

                let entity = ImageCacheEntity()

                entity.key = key.absoluteString
                entity.original = original
                entity.thumbnail = thumbnail

                do {
                    try bgRealm.write {
                        bgRealm.add(entity, update: true)
                    }

                    bgRealm.invalidate()
                } catch {
//                    os_log("Failed to save cached image to disk: %{public}@",
//                           log: self.log,
//                           type: .error,
//                           String(describing: error))
                }
            }
        }
    }

}

private final class ImageDownloadOperation: Operation {

    var imageCompletionHandler: ImageDownloadCompletionBlock?

    let url: URL
    let thumbnailHeight: CGFloat

    let cacheProvider: ImageCacheProvider

    init(url: URL, cache: ImageCacheProvider, thumbnailHeight: CGFloat = 1.0) {
        self.url = url
        cacheProvider = cache
        self.thumbnailHeight = thumbnailHeight
    }

    public override var isAsynchronous: Bool {
        return true
    }

    internal var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }

    public override var isExecuting: Bool {
        return _executing
    }

    internal var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }

    public override var isFinished: Bool {
        return _finished
    }

    override func start() {
        _executing = true

        let urlRequest = Environment.urlRequest(url: url)

        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let welf = self else { return }

            guard !welf.isCancelled else {
                welf._executing = false
                welf._finished = true
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.async { welf.imageCompletionHandler?(welf.url, nil, nil) }
                welf._executing = false
                welf._finished = true
                return
            }

            guard httpResponse.statusCode == 200 else {
                DispatchQueue.main.async { welf.imageCompletionHandler?(welf.url, nil, nil) }
                welf._executing = false
                welf._finished = true
                return
            }

            guard data.count > 0 else {
                DispatchQueue.main.async { welf.imageCompletionHandler?(welf.url, nil, nil) }
                welf._executing = false
                welf._finished = true
                return
            }

            guard let originalImage = UIImage(data: data) else {
                DispatchQueue.main.async { welf.imageCompletionHandler?(welf.url, nil, nil) }
                welf._executing = false
                welf._finished = true
                return
            }

            guard !welf.isCancelled else {
                welf._executing = false
                welf._finished = true
                return
            }

            let thumbnailImage = originalImage.resized(to: welf.thumbnailHeight)

//            originalImage.cacheMode = .never
//            thumbnailImage.cacheMode = .never

            DispatchQueue.main.async {
                welf.imageCompletionHandler?(welf.url, originalImage, thumbnailImage)
            }

            welf.cacheProvider.cacheImage(for: welf.url, original: data, thumbnail: thumbnailImage.pngData())

            welf._executing = false
            welf._finished = true
        }.resume()
    }

}

extension UIImage {

    func resized(to maxHeight: CGFloat) -> UIImage {
        let scaleFactor = maxHeight / size.height
        let newWidth = size.width * scaleFactor
        let newHeight = size.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        func isSameSize(_ newSize: CGSize) -> Bool {
            return size == newSize
        }

        func scaleImage(_ newSize: CGSize) -> UIImage? {
            func getScaledRect(_ newSize: CGSize) -> CGRect {
                let ratio   = max(newSize.width / size.width, newSize.height / size.height)
                let width   = size.width * ratio
                let height  = size.height * ratio
                return CGRect(x: 0, y: 0, width: width, height: height)
            }

            func _scaleImage(_ scaledRect: CGRect) -> UIImage? {
                UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0.0);
                draw(in: scaledRect)
                let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
                UIGraphicsEndImageContext()
                return image
            }
            return _scaleImage(getScaledRect(newSize))
        }

        return isSameSize(newSize) ? self : scaleImage(newSize)!
    }

}

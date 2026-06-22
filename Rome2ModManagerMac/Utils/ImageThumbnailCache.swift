//
//  ImageThumbnailCache.swift
//  Rome2ModManagerMac
//
//  两级缓存 + CGImageSource 快速缩略图生成
//  第一次打开也能秒加载 MOD 预览图
//

import Foundation
import SwiftUI
import CryptoKit

/// 高性能 MOD 缩略图缓存
/// - 一级：NSCache 内存缓存（线程安全，自动清理）
/// - 二级：磁盘缓存 ~/Library/Caches/ ，App 重启后仍存活
/// - 核心：CGImageSourceCreateThumbnailAtIndex 不解码原图直接出缩略图
final class ImageThumbnailCache {
    static let shared = ImageThumbnailCache()

    // MARK: - 内存缓存

    private let memoryCache: NSCache<NSURL, NSImage> = {
        let c = NSCache<NSURL, NSImage>()
        c.countLimit = 80          // 最多 80 张缩略图
        c.totalCostLimit = 30 * 1024 * 1024  // 上限 ~30 MB
        return c
    }()

    // MARK: - 磁盘缓存目录

    private let diskDir: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("com.sundaylee.Rome2ModManagerMac/thumbnails")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// 磁盘文件名：URL path 的 SHA256（跨启动一致）
    private func diskFileName(for url: URL) -> String {
        let data = Data(url.path.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func diskURL(for url: URL) -> URL {
        diskDir.appendingPathComponent(diskFileName(for: url) + ".thumb.png")
    }

    // MARK: - 公共 API

    /// 获取缩略图（同步，取缓存用，极快）
    /// 先在内存找 → 磁盘找 → 都没有返回 nil
    func cachedThumbnail(for url: URL) -> NSImage? {
        let nsURL = url as NSURL

        // 1. 内存
        if let img = memoryCache.object(forKey: nsURL) {
            return img
        }

        // 2. 磁盘
        let fileURL = diskURL(for: url)
        if let data = try? Data(contentsOf: fileURL),
           let img = NSImage(data: data) {
            memoryCache.setObject(img, forKey: nsURL)
            return img
        }

        return nil
    }

    /// 生成并缓存缩略图（同步，调用方应放后台线程）
    /// 使用 CGImageSource 不解码原图直接出缩略图，快 5-20 倍
    func generateAndCache(for url: URL, maxSize: CGFloat = 300) -> NSImage? {
        let nsURL = url as NSURL

        // 先查缓存
        if let img = memoryCache.object(forKey: nsURL) {
            return img
        }

        let diskFile = diskURL(for: url)
        if let data = try? Data(contentsOf: diskFile),
           let img = NSImage(data: data) {
            memoryCache.setObject(img, forKey: nsURL)
            return img
        }

        // 🔑 核心：CGImageSource 缩略图 → 不解码全图
        guard let thumbnail = Self.makeThumbnail(url: url, maxSize: maxSize) else {
            return nil
        }

        // 存入内存
        memoryCache.setObject(thumbnail, forKey: nsURL)

        // 异步写磁盘（不阻塞返回）
        let diskTarget = diskFile
        DispatchQueue.global(qos: .utility).async {
            if let png = thumbnail.pngData() {
                try? png.write(to: diskTarget)
            }
        }

        return thumbnail
    }

    /// 后台批量预加载（TaskGroup 并发）
    func preloadAll(urls: [URL], maxSize: CGFloat = 300) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    _ = self.generateAndCache(for: url, maxSize: maxSize)
                }
            }
        }
    }

    // MARK: - 内部：CGImageSource 缩略图

    private static func makeThumbnail(url: URL, maxSize: CGFloat) -> NSImage? {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            // 回退：传统方式
            return NSImage(contentsOf: url)?.thumbnail(maxWidth: maxSize, maxHeight: maxSize)
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(maxSize, maxSize)
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(src, 0, options as CFDictionary) else {
            return nil
        }

        let image = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        return image
    }
}

// MARK: - NSImage 辅助

extension NSImage {
    func pngData() -> Data? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        rep.size = self.size
        return rep.representation(using: .png, properties: [:])
    }

    func thumbnail(maxWidth: CGFloat, maxHeight: CGFloat) -> NSImage {
        let ratio = min(maxWidth / size.width, maxHeight / size.height, 1.0)
        let newSize = NSSize(width: size.width * ratio, height: size.height * ratio)
        let thumb = NSImage(size: newSize)
        thumb.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: newSize),
                  from: NSRect(origin: .zero, size: size),
                  operation: .copy, fraction: 1.0)
        thumb.unlockFocus()
        return thumb
    }
}

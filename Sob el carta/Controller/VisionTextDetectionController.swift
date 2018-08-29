//
//  VisionTextDetectionController.swift
//  Sob el carta
//
//  Created by MedAmine on 8/28/18.
//  Copyright © 2018 AppGeek+. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

@available(iOS 11.0, *)
class VisionTextDetectionController: NSObject {

    var delegate:VisionTextDetectionControllerDelegate?
    
    private var session: AVCaptureSession!
    private var deviceOutput: AVCaptureVideoDataOutput!
    
    private var requests: [VNRequest] = []
    
    private var lastOutputedSampleBuffer: CMSampleBuffer?
    
    private var timerForImageWithTextApproval: Timer?
    
    private var detectionStarted = false
    
    init(session: AVCaptureSession) {
        super.init()
        
        self.session = session
        
        deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        session.addOutput(deviceOutput)
        
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: detectTextHandler)
        self.requests = [textRequest]
    }
    
    func start(){
        detectionStarted = true
    }
    
    func stop(){
        detectionStarted = false
        timerForImageWithTextApproval?.invalidate()
        timerForImageWithTextApproval = nil
    }
    
    func getLastImageCaptured() -> UIImage? {
        guard let lastOutputedSampleBuffer = lastOutputedSampleBuffer else {
            return nil
        }
        
        return getImageFromSampleBuffer(sampleBuffer: lastOutputedSampleBuffer)
    }
    
    private func detectTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            return
        }
        
        let result = observations.map { (elemnt: Any) -> VNTextObservation? in
            return elemnt as? VNTextObservation
        }
        
        if result.count > 0 {
            if timerForImageWithTextApproval == nil {
                DispatchQueue.main.async {
                    self.timerForImageWithTextApproval = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.timerForImageWithTextApprovalValidated), userInfo: nil, repeats: false)
                }
            }
        } else {
            if timerForImageWithTextApproval != nil {
                timerForImageWithTextApproval?.invalidate()
                timerForImageWithTextApproval = nil
            }
        }
    }
    
    @objc private func timerForImageWithTextApprovalValidated(){
        guard detectionStarted else {
            return
        }
        
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(setTimerForImageWithTextApprovalToNil), userInfo: nil, repeats: false)
        
        guard let lastImageCaptured = getLastImageCaptured() else {
            return
        }
        delegate?.imageContainTextDetected(image: lastImageCaptured)
    }
    
    @objc private func setTimerForImageWithTextApprovalToNil(){
        timerForImageWithTextApproval = nil
    }
    
    private func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) ->UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation:.right)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
    
}

//MARK: - Extension : AVCaptureVideoDataOutputSampleBufferDelegate {
@available(iOS 11.0, *)
extension VisionTextDetectionController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard detectionStarted else {
            return
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation.right, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(requests)
        } catch _ {
        }
        
        lastOutputedSampleBuffer = sampleBuffer
    }
}

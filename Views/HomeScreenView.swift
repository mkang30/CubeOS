import SwiftUI
import SceneKit
import CoreMotion
import ModelIO

/// View where all the core action takes place
struct HomeScreenView: View {
  let scene: CubeScene
  let camera: SCNNode
  var body: some View {
    GeometryReader { proxy in
      VStack {
        SceneView(scene: scene, pointOfView: camera)
          .gesture(DragGesture().onChanged(scene.dragDelegate.onChanged).onEnded(scene.dragDelegate.onEnded))
      }.ignoresSafeArea()
    }
  }
  
  
  /// Sets up a camera node and returrns
  /// - Returns: camera node
  static func createCameraNode(width: CGFloat) -> SCNNode {
    let cameraNode = SCNNode()
    cameraNode.position = SCNVector3(0,10.15,10.4*width/390)
    cameraNode.eulerAngles = SCNVector3(0,0,0)
    cameraNode.scale = SCNVector3(1,1,1)
    cameraNode.camera = SCNCamera()
    return cameraNode
  }
   
}


/// 3D Scene that contains the design prototype.
class CubeScene: SCNScene {
  
  
  var dragDelegate: DragDelegate
  
  
  /// Initializes and sets up all node components of teh scene. Utilizing DragDelegate object to convert from the
  /// HomeScreenView 2D space to the scene 3D space
  init(width: CGFloat, height: CGFloat) {
    // Initialize all nodes and set up positions
    let center = Cube(frameDim: CGPoint(x:BOUND_CENTER.right-BOUND_CENTER.left, y:BOUND_CENTER.bot-BOUND_CENTER.top), cubeDim: 4)
    center.position.y = 9.1
    let topLeft = Cube(frameDim: CGPoint(x:BOUND_TOP_LEFT.right-BOUND_TOP_LEFT.left, y:BOUND_TOP_LEFT.bot-BOUND_TOP_LEFT.top), cubeDim: 1)
    topLeft.scale = SCNVector3(1.98,1.98,1.98)
    topLeft.position = SCNVector3(-1.037, 12.2, 1)
    let topRight = Cube(frameDim: CGPoint(x:BOUND_TOP_RIGHT.right-BOUND_TOP_RIGHT.left, y:BOUND_TOP_RIGHT.bot-BOUND_TOP_RIGHT.top), cubeDim: 2)
    topRight.position = SCNVector3(1, 12.2, 1)
    let botPrism = RectPrism(frameDim: CGPoint(x:BOUND_BOT.right-BOUND_BOT.left, y:BOUND_BOT.bot-BOUND_BOT.top), cubeDim: 4, isBox: true)
    botPrism.position.y = 6.5
    let topPrism = RectPrism(frameDim: CGPoint(x:BOUND_TOP.right-BOUND_TOP.left, y:BOUND_TOP.bot-BOUND_TOP.top), cubeDim: 4)
    topPrism.position.y = 13.8
    
    dragDelegate = DragDelegate(botPrism: botPrism, centerCube: center, topRightCube: topRight, topLeftCube: topLeft, topPrism: topPrism)
    
    super.init()
    
    //add to the scene
    self.rootNode.addChildNode(topLeft)
    self.rootNode.addChildNode(topRight)
    self.rootNode.addChildNode(botPrism)
    self.rootNode.addChildNode(topPrism)
    self.rootNode.addChildNode(center)
    addBackground()
    addOmniLight()
    
    //apply all the textures in bulks
    setupImageCube(cube: center,
                   commons: ["black", "red", "green", "white", "purple", "blue"],
                   counts: 16)
    setupImageCube(cube: topRight,
                   commons: ["app1", "app2", "app3", "app4", "app5", "app6"],
                   counts: 4)
    setupImageCube(cube: topLeft,
                   commons: ["widget1", "widget2", "widget3", "widget4", "widget5", "widget6"],
                   counts: 1)
    
    let botPrismImages = Helper.loadImageSequential(common: "bot", count: 16)
    botPrism.applyImagesBoxes(images: botPrismImages)
    let botPrismTopImages = Helper.loadImageSequential(common: "al", count: 16)
    botPrism.applyTopImagesBoxes(images: botPrismTopImages)
    let topPrismImages = Helper.loadImageSequential(common: "rect", count: 4)
    topPrism.applyImages(images: topPrismImages)
  }
  
  /// Helper function for applying textures to Cubes in bul
  /// - Parameters:
  ///   - cube: cube
  ///   - commons: common image name part
  ///   - counts: number of images
  private func setupImageCube(cube: Cube, commons: [String], counts: Int) {
    for i in 0..<6 {
      let face = CubeFace(rawValue: i)
      let images = Helper.loadImageSequential(common: commons[i], count: counts)
      cube.applyImagesCubeFace(face: face!, images: images)
    }
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Self-explanatory
  private func addBackground() {
    self.background.contents = UIImage(named:"bg2")
    self.lightingEnvironment.contents = self.background.contents
  }
  
  /// Self-explanatory
  private func addOmniLight() {
    let omniLightNode = SCNNode()
    omniLightNode.light = SCNLight()
    omniLightNode.light?.type = SCNLight.LightType.omni
    omniLightNode.light?.color = UIColor(white: 1, alpha: 1)
    omniLightNode.position = SCNVector3Make(0, 15, 15)
    self.rootNode.addChildNode(omniLightNode)
  }
  
  
}



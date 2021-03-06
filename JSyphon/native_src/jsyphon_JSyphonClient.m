#import <JavaVM/JavaVM.h>
#import <JavaNativeFoundation/JavaNativeFoundation.h>	// JNI Cocoa helper 
#import <JavaVM/jni.h>

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <Syphon/Syphon.h>

#import <SyphonNameboundClient.h>

#import <OpenGL/CGLMacro.h>

static SyphonNameboundClient* mClient;

JNIEXPORT void JNICALL Java_jsyphon_JSyphonClient_init(JNIEnv * env, jobject jobj)
{
    JNF_COCOA_ENTER(env);

    mClient = [[SyphonNameboundClient alloc] init]; 

    JNF_COCOA_EXIT(env);
}

JNIEXPORT void JNICALL Java_jsyphon_JSyphonClient_setApplicationName(JNIEnv * env, jobject jobj, jstring appName)
{
    JNF_COCOA_ENTER(env);
    
    NSString* name = JNFJavaToNSString(env, appName);
		        
	[(SyphonNameboundClient*)mClient setAppName:name];
    
    JNF_COCOA_EXIT(env);    
}

JNIEXPORT void JNICALL Java_jsyphon_JSyphonClient_setServerName(JNIEnv * env, jobject jobj, jstring serverName)
{
    JNF_COCOA_ENTER(env);
        
    NSString* name = JNFJavaToNSString(env, serverName);
		
    if([name length] == 0)
        name = nil;
        
	[(SyphonNameboundClient*)mClient setName:name];
    
    JNF_COCOA_EXIT(env);      
}

JNIEXPORT jboolean JNICALL Java_jsyphon_JSyphonClient_isValid(JNIEnv * env, jobject jobj)
{
    jboolean val = JNI_FALSE;
    
    JNF_COCOA_ENTER(env);
    
	[(SyphonNameboundClient*)mClient lockClient];
	SyphonClient *client = [(SyphonNameboundClient*)mClient client];
	
    if([client isValid])
        val = JNI_TRUE;
    
	[(SyphonNameboundClient*)mClient unlockClient];	
    
    JNF_COCOA_EXIT(env);
    
    return val;
}

JNIEXPORT jobject JNICALL Java_jsyphon_JSyphonClient_serverDescription(JNIEnv * env, jobject jobj)
{
    jobject serverdesc = nil;
    
    JNF_COCOA_ENTER(env);

	[(SyphonNameboundClient*)mClient lockClient];
	SyphonClient *client = [(SyphonNameboundClient*)mClient client];	
	
    NSDictionary* desc = [client serverDescription];
    
    JNFTypeCoercer* coecer = [JNFDefaultCoercions defaultCoercer];
    [JNFDefaultCoercions addMapCoercionTo:coecer];
    
    serverdesc = [coecer coerceNSObject:desc withEnv:env];
    
	[(SyphonNameboundClient*)mClient unlockClient];		
	
    JNF_COCOA_EXIT(env);

    return serverdesc;
}


JNIEXPORT jboolean JNICALL Java_jsyphon_JSyphonClient_hasNewFrame(JNIEnv * env, jobject jobj)
{
    jboolean val = JNI_FALSE;
    
    JNF_COCOA_ENTER(env);
    
	[(SyphonNameboundClient*)mClient lockClient];
	SyphonClient *client = [(SyphonNameboundClient*)mClient client];
	
    if([client hasNewFrame])
        val = JNI_TRUE;
    
	[(SyphonNameboundClient*)mClient unlockClient];
	
    JNF_COCOA_EXIT(env);
    
    return val;    
}

// Commented out until we figure out how to properly coerce arbitrary objects from Objective-C to Java
/*
JNIEXPORT jobject JNICALL Java_jsyphon_JSyphonClient_newFrameImageForContext(JNIEnv * env, jobject jobj)
{
	jobject frameimg = nil;
	
	JNF_COCOA_ENTER(env);
		
	[(SyphonNameboundClient*)mClient lockClient];
	SyphonClient *client = [(SyphonNameboundClient*)mClient client];
	
	SyphonImage* img = [client newFrameImageForContext:CGLGetCurrentContext()];	
		
	JNFTypeCoercer *coercer = [[[JNFTypeCoercer alloc] init] autorelease];

    // TODO: we need to implement a coercion between SyphonImage and JSyphonImage:
	// https://developer.apple.com/library/mac/#documentation/CrossPlatform/Reference/JNFTypeCoercer_Class/Reference/JNFTypeCoercer.html
	// https://developer.apple.com/library/mac/#documentation/CrossPlatform/Reference/JNFTypeCoercion_Protocol/Reference/NSView.html
	// https://developer.apple.com/library/mac/#documentation/CrossPlatform/Reference/JNFDefaultCoercions_Class/Reference/JNFDefaultCoercions.html
	// http://cr.openjdk.java.net/~michaelm/7113349/1/jdk/new/src/macosx/native/apple/applescript/NS_Java_ConversionUtils.m.html
	//[coercer addCoercion:[[[JNFVectorCoercion alloc] init] autorelease] forNSClass:[SyphonImage class] javaClass:@"jsyphon/JSyphonImage"];	
    //frameimg = [coecer coerceNSObject:img withEnv:env];	
	
	[(SyphonImage*)img release];
	
	[(SyphonNameboundClient*)mClient unlockClient];
	
	JNF_COCOA_EXIT(env);
	
	return frameimg;	
}
 */

JNIEXPORT jobject JNICALL Java_jsyphon_JSyphonClient_newFrameDataForContext(JNIEnv * env, jobject jobj)
{
	jobject imgdata = nil;
	
	JNF_COCOA_ENTER(env);
	
	[(SyphonNameboundClient*)mClient lockClient];
	SyphonClient *client = [(SyphonNameboundClient*)mClient client];
	
	SyphonImage* img = [client newFrameImageForContext:CGLGetCurrentContext()];	

//	NSLog(@"the syphon image at newFrameDataForContext = %@", img);
		
	NSSize texSize = [img textureSize];

	NSNumber *name = [NSNumber numberWithInt:[img textureName]];
	NSNumber *width = [NSNumber numberWithFloat:texSize.width];
	NSNumber *height = [NSNumber numberWithFloat:texSize.height];
	
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys: 
						 name, @"name", 
						 width, @"width", 
						 height, @"height", 
						 nil];
	
	
	JNFTypeCoercer* coecer = [JNFDefaultCoercions defaultCoercer];
    [JNFDefaultCoercions addMapCoercionTo:coecer];
    
    imgdata = [coecer coerceNSObject:dic withEnv:env];
	
	[(SyphonImage*)img release];
	
	[(SyphonNameboundClient*)mClient unlockClient];	
	
	JNF_COCOA_EXIT(env);
	
	return imgdata;	
}

JNIEXPORT void JNICALL Java_jsyphon_JSyphonClient_stop(JNIEnv * env, jobject jobj)
{
    JNF_COCOA_ENTER(env);
  
    [(SyphonNameboundClient*)mClient lockClient];
	SyphonClient *client = [(SyphonNameboundClient*)mClient client];
	
    [client stop];
    
	[(SyphonNameboundClient*)mClient unlockClient];	

    JNF_COCOA_EXIT(env);
}

/*
static SyphonClient* _myClient;

JNIEXPORT void JNICALL Java_jsyphon_JSyphonClient_initWithServerDescriptionAndOptions(JNIEnv * env, jobject jobj, jobject jdesc, jobject jopts)
{
    JNF_COCOA_ENTER(env);
	
    JNFTypeCoercer* coecer = [JNFDefaultCoercions defaultCoercer];
    [JNFDefaultCoercions addMapCoercionTo:coecer];
	
    NSDictionary* desc = [coecer coerceJavaObject:jdesc withEnv:env];
    
    _myClient = [[SyphonClient alloc] initWithServerDescription:desc options:nil newFrameHandler:NULL];
 
    JNF_COCOA_EXIT(env);
}

JNIEXPORT jboolean JNICALL Java_jsyphon_JSyphonClient_isValid(JNIEnv * env, jobject jobj)
{
    jboolean val = JNI_FALSE;
    
    JNF_COCOA_ENTER(env);
    
    if([_myClient isValid])
        val = JNI_TRUE;
 
    JNF_COCOA_EXIT(env);
    
    return val;
}

JNIEXPORT jobject JNICALL Java_jsyphon_JSyphonClient_serverDescription(JNIEnv * env, jobject jobj)
{
    jobject serverdesc = NULL;
    
    JNF_COCOA_ENTER(env);
	
    NSDictionary* desc = [_myClient serverDescription];
    
    JNFTypeCoercer* coecer = [JNFDefaultCoercions defaultCoercer];
    [JNFDefaultCoercions addMapCoercionTo:coecer];
    
    serverdesc = [coecer coerceNSObject:desc withEnv:env];
 
    JNF_COCOA_EXIT(env);
	
    return serverdesc;
}

JNIEXPORT jboolean JNICALL Java_jsyphon_JSyphonClient_hasNewFrame(JNIEnv * env, jobject jobj)
{
    jboolean val = JNI_FALSE;
 
    JNF_COCOA_ENTER(env);
 
    if([_myClient hasNewFrame])
	val = JNI_TRUE;
 
    JNF_COCOA_EXIT(env);
 
    return val;    
}

JNIEXPORT void JNICALL Java_jsyphon_JSyphonClient_stop(JNIEnv * env, jobject jobj)
{
	JNF_COCOA_ENTER(env);	
	
	[_myClient stop];
	
	JNF_COCOA_EXIT(env);
}
*/
//
//  EPPZSwizzler.m
//  eppz!swizzler
//
//  Created by Borbás Geri on 27/02/14
//  Copyright (c) 2013 eppz! development, LLC.
//
//  follow http://www.twitter.com/_eppz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "EPPZSwizzler.h"

#define MyLog(s, ...) [EPPZSwizzler _MyLog:s,##__VA_ARGS__];


static char associationKeyKey;


@interface EPPZSwizzler ()
+(NSString*)setterMethodNameForPropertyName:(NSString*) propertyName;
@end


@implementation EPPZSwizzler

+(void)_MyLog:(NSString *)format, ...
{
    
    NSString* myformat = [[NSString alloc]initWithFormat:@"[ERROR]EPPZSwizzler:%@",format];
    va_list args;
    va_start(args, format);
    NSString* str = [[NSString alloc] initWithFormat:myformat arguments:args];
    va_end(args);
    if([str length]<=1024){
        NSLog(@"%@",str);
    }
    else{
        while (true) {
            if([str length] > 1024){

                NSString* splitStr = [[NSString alloc]initWithString:[str substringToIndex:1024]];
                str = [[NSString alloc]initWithString:[str substringFromIndex:1024]];
                NSLog(@"%@",splitStr);
            }
            else{
                NSLog(@"%@",str);
                break;
            }
        }
    }
    
}



#pragma mark - Method swizzlers

+(bool) hasClassMethod:(SEL) selector
               ofClass:(Class) targetClass {

    Method targetMethod = class_getClassMethod(targetClass, selector);
    return (targetMethod != nil);
}

+(bool) hasInstanceMethod:(SEL) selector
                  ofClass:(Class) targetClass {
    Method targetMethod = class_getInstanceMethod(targetClass, selector);
    return (targetMethod != nil);
}

+(void) swapInstanceMethod:(SEL)oneSelector
        withInstanceMethod:(SEL)otherSelector
                   ofClass:(Class)class {
    // Get methods.
    Method oneMethod = class_getInstanceMethod(class, oneSelector);
    Method otherMethod = class_getInstanceMethod(class, otherSelector);
    
    // Checks.
    if (oneMethod == nil)
    { MyLog(@"1 Instance method `%@` not found on class %@", NSStringFromSelector(oneSelector), class); return; };
    if (otherMethod == nil)
    { MyLog(@"2 Instance method `%@` not found on class %@", NSStringFromSelector(otherSelector), class); return; };
    
    // Exchange.
    method_exchangeImplementations(oneMethod, otherMethod);
    
    MyLog(@"Exchanged instance method `%@` with `%@` in %@", NSStringFromSelector(oneSelector), NSStringFromSelector(otherSelector), class);
}

+(void) swapClassMethod:(SEL)oneSelector
        withClassMethod:(SEL)otherSelector
                ofClass:(Class)class {
    // Get methods.
    Method oneMethod = class_getClassMethod(class, oneSelector);
    Method otherMethod = class_getClassMethod(class, otherSelector);
    
    // Checks.
    if (oneMethod == nil)
    { MyLog(@"3 Class method `%@` not found on class %@", NSStringFromSelector(oneSelector), class); return; };
    if (otherMethod == nil)
    { MyLog(@"4 Class method `%@` not found on class %@", NSStringFromSelector(otherSelector), class); return; };
    
    // Exchange.
    method_exchangeImplementations(oneMethod, otherMethod);
    
    MyLog(@"Exchanged class method `%@` with `%@` in %@", NSStringFromSelector(oneSelector), NSStringFromSelector(otherSelector), class);
}

+(void) replaceClassMethod:(SEL)selector
                   ofClass:(Class)targetClass
                 fromClass:(Class)sourceClass {
    // Get methods.
    Method targetMethod = class_getClassMethod(targetClass, selector);
    Method sourceMethod = class_getClassMethod(sourceClass, selector);
    
    // Checks.
    if (sourceMethod == nil)
    { MyLog(@"5 Class method `%@` not found on source class %@", NSStringFromSelector(selector), sourceClass); return; };
    
    if (targetMethod == nil)
    { MyLog(@"6 Class method `%@` not found on target class %@", NSStringFromSelector(selector), targetClass); return; };
    
    // Replace target method.
    IMP previousTargetMethod = method_setImplementation(targetMethod,
                                                        method_getImplementation(sourceMethod));
    
    MyLog(@"Replaced method `%@` of %@ from %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (previousTargetMethod) ? @"success" : @"error");
}

+(void) replaceInstanceMethod:(SEL)selector
                      ofClass:(Class)targetClass
                    fromClass:(Class)sourceClass {
    // Get methods.
    Method targetMethod = class_getInstanceMethod(targetClass, selector);
    Method sourceMethod = class_getInstanceMethod(sourceClass, selector);
    
    // Checks.
    if (sourceMethod == nil)
    { MyLog(@"7 Instance method `%@` not found on source class %@", NSStringFromSelector(selector), sourceClass); return; };
    
    if (targetMethod == nil)
    { MyLog(@"8 Instance method `%@` not found on target class %@", NSStringFromSelector(selector), targetClass); return; };
    
    // Replace target method.
    IMP previousTargetMethod = method_setImplementation(targetMethod,
                                                        method_getImplementation(sourceMethod));
    
    if(previousTargetMethod!=nil){
    MyLog(@"Replaced instance method `%@` of %@ from %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (previousTargetMethod) ? @"success" : @"error");
    }
    else{
    MyLog(@"Replaced instance method `%@` of %@ from %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (previousTargetMethod) ? @"success" : @"error");
    }
}

+(void) addClassMethod:(SEL)selector
               toClass:(Class)targetClass
             fromClass:(Class)sourceClass {
    
    // Get methods.
    Method method = class_getClassMethod(sourceClass, selector);
    
    // Checks.
    if (method == nil)
    { MyLog(@"9 Class method `%@` not found on source class %@", NSStringFromSelector(selector), sourceClass); return; };
    
    targetClass = object_getClass((id)targetClass);
    BOOL success = class_addMethod(targetClass,
                                   selector,
                                   method_getImplementation(method),
                                   method_getTypeEncoding(method));
    if(success){
    MyLog(@"Added class method `%@` of %@ to %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (success) ? @"success" : @"error");
    }
    else{
    MyLog(@"Added class method `%@` of %@ to %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (success) ? @"success" : @"error");
    }
}

+(void) addInstanceMethod:(SEL)selector
                  toClass:(Class)targetClass
                fromClass:(Class)sourceClass {
    [self addInstanceMethod:selector
                    toClass:targetClass
                  fromClass:sourceClass
                         as:selector];
}

+(void) addInstanceMethod:(SEL)selector
                  toClass:(Class)targetClass
                fromClass:(Class)sourceClass
                       as:(SEL)targetSelector {
    // Get method.
    Method method = class_getInstanceMethod(sourceClass, selector);
    
    // Checks.
    if (method == nil)
    { MyLog(@"10 Instance method `%@` not found on source class %@", NSStringFromSelector(selector), sourceClass); return; };
    
    // Add method.
    BOOL success = class_addMethod(targetClass,
                                   targetSelector,
                                   method_getImplementation(method),
                                   method_getTypeEncoding(method));
    if(success){
        MyLog(@"Added instance method `%@` of %@ to %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (success) ? @"success" : @"error");
    }
    else{
        MyLog(@"Added instance method `%@` of %@ to %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (success) ? @"success" : @"error");
    }
}


#pragma mark - Property swizzlers

+(NSString*) setterMethodNameForPropertyName:(NSString*)propertyName {
    // Checks.
    if (propertyName.length == 0) return propertyName;
    
    NSString *firstChar = [[propertyName substringToIndex:1] capitalizedString];
    NSString *andTheRest = [propertyName substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:", firstChar, andTheRest];
}

+(void) addPropertyNamed:(NSString*)propertyName
                 toClass:(Class) targetClass
               fromClass:(Class) sourceClass {
    // Get property.
    const char *name = propertyName.UTF8String;
    objc_property_t property = class_getProperty(sourceClass, name);
    unsigned int attributesCount = 0;
    objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributesCount);

    // Checks.
    if (property == nil)
    { MyLog(@"Property `%@` not found on source class %@", propertyName, sourceClass); return; };
    
    // Add (or replace) property.
    BOOL success = class_addProperty(targetClass, name, attributes, attributesCount);
    if (success == NO)
    {
        class_replaceProperty(targetClass, name, attributes, attributesCount);
        MyLog(@"Replaced property `%@` of %@ to %@ with %@", propertyName, sourceClass, targetClass, (success) ? @"success" : @"error");
    }
    else
    { MyLog(@"Added property `%@` of %@ to %@ with %@", propertyName, sourceClass, targetClass, (success) ? @"success" : @"error"); }
    
    // Add getter.
    [self addInstanceMethod:NSSelectorFromString(propertyName) toClass:targetClass fromClass:sourceClass];
    
    // Add setter.
    NSString *setterMethodName = [self setterMethodNameForPropertyName:propertyName];
    [self addInstanceMethod:NSSelectorFromString(setterMethodName) toClass:targetClass fromClass:sourceClass];
}

+(void) synthesizePropertyNamed:(NSString*)propertyName
                         ofKind:(Class)kind
                       forClass:(Class)targetClass
                     withPolicy:(EPPZSwizzlerProperryAssociationPolicy)policy {
    // Get type encoding.
    const char *typeEncoding = @encode(typeof(kind));
    
    // Associate the key for the property to the class itself.
    NSString *keyObject = [NSString stringWithFormat:@"%@Key", propertyName];
    void *key = (__bridge void*)keyObject;
    objc_setAssociatedObject(targetClass, &associationKeyKey, keyObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Getter implementation.
    IMP getterImplementation = imp_implementationWithBlock(^(id self)
    { return (id)objc_getAssociatedObject(self, key); });
    
    //philip fix for warning
    objc_AssociationPolicy m_policy;
    switch (policy) {
        case assign:
            m_policy = OBJC_ASSOCIATION_ASSIGN;
            break;
        case nonatomic_retain:
            m_policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
            break;
        case nonatomic_copy:
            m_policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
            break;
        case retain:
            m_policy = OBJC_ASSOCIATION_RETAIN;
            break;
        case copy:
            m_policy = OBJC_ASSOCIATION_COPY;
            break;
        default:
            break;
    }
    // Setter implementation.
    IMP setterImplementation = imp_implementationWithBlock(^(id self, id value)
    { objc_setAssociatedObject(self, key, value, m_policy); });
    
    // Add getter.
    BOOL success = class_addMethod(targetClass,
                                   NSSelectorFromString(propertyName),
                                   getterImplementation,
                                   typeEncoding);
    if(success){
    MyLog(@"Added synthesized getter `%@` to %@ with %@", propertyName, targetClass, (success) ? @"success" : @"error");
    }else{
        MyLog(@"Added synthesized getter `%@` to %@ with %@", propertyName, targetClass, (success) ? @"success" : @"error");
        
    }
    // Add setter.
    NSString *setterMethodName = [self setterMethodNameForPropertyName:propertyName];
    success = class_addMethod(targetClass,
                              NSSelectorFromString(setterMethodName),
                              setterImplementation,
                              typeEncoding);
    if(success){
    MyLog(@"Added synthesized setter `%@` to %@ with %@", setterMethodName, targetClass, (success) ? @"success" : @"error");
    }else{
        MyLog(@"Added synthesized setter `%@` to %@ with %@", setterMethodName, targetClass, (success) ? @"success" : @"error");
        
    }
}



@end

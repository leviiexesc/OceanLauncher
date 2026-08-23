--- a/Natives/external/LTW/ltw/src/main/tinywrapper/shader_wrapper.c
+++ b/Natives/external/LTW/ltw/src/main/tinywrapper/shader_wrapper.c
@@ -8,11 +8,15 @@
 #include "vgpu_shaderconv/shaderconv.h"
 #include "glsl_optimizer/src/code/c_wrapper.h"
 #include <GLES3/gl3.h>
+#include <stdint.h>
+#include <stdio.h>
 #include <string.h>
 #include "string_utils.h"
 #include "egl.h"
 #include "proc.h"
 
+#define GL_HANDLE_KEY(handle) ((void *)(uintptr_t)(handle))
+
 typedef struct {
     GLenum shader_type;
     const GLchar* source;
@@ -32,14 +36,14 @@
         printf("LTWShdrWp: failed to allocate program_info\n");
         abort();
     }
-    unordered_map_put(current_context->program_map, (void*)phys_program, prog_info);
+    unordered_map_put(current_context->program_map, GL_HANDLE_KEY(phys_program), prog_info);
     return phys_program;
 }
 
 void glDeleteProgram(GLuint program) {
     if(!current_context) return;
     es3_functions.glDeleteProgram(program);
-    program_info_t *old_programinfo = unordered_map_remove(current_context->program_map, (void*)program);
+    program_info_t *old_programinfo = unordered_map_remove(current_context->program_map, GL_HANDLE_KEY(program));
     if(old_programinfo == NULL) return;
     for(GLuint i = 0; i < MAX_DRAWBUFFERS; i++) {
         const GLchar* binding = old_programinfo->colorbindings[i];
@@ -52,8 +56,8 @@
                         GLuint shader) {
     if(!current_context) return;
     es3_functions.glAttachShader(program, shader);
-    program_info_t* program_info = unordered_map_get(current_context->program_map, (void*)program);
-    shader_info_t* shader_info = unordered_map_get(current_context->shader_map, (void*)shader);
+    program_info_t* program_info = unordered_map_get(current_context->program_map, GL_HANDLE_KEY(program));
+    shader_info_t* shader_info = unordered_map_get(current_context->shader_map, GL_HANDLE_KEY(shader));
     if(program_info == NULL || shader_info == NULL || shader_info->shader_type != GL_FRAGMENT_SHADER) return;
     program_info->frag_shader = shader;
 }
@@ -62,7 +66,7 @@
                                 GLuint colorNumber,
                                 const char * name) {
     if(!current_context) return;
-    program_info_t *program_info = unordered_map_get(current_context->program_map, (void*)program);
+    program_info_t *program_info = unordered_map_get(current_context->program_map, GL_HANDLE_KEY(program));
     if(program_info == NULL || colorNumber >= MAX_DRAWBUFFERS) return;
     // Insert binding name at the specific index
     GLchar** pname = &program_info->colorbindings[colorNumber];
@@ -73,7 +77,7 @@
 
 void glGetShaderiv(GLuint shader, GLuint pname, GLint* params) {
     if(!current_context) return;
-    shader_info_t* shader_info = unordered_map_get(current_context->shader_map, (void*)shader);
+    shader_info_t* shader_info = unordered_map_get(current_context->shader_map, GL_HANDLE_KEY(shader));
     if(shader_info != NULL && shader_info->shader_type == GL_FRAGMENT_SHADER && pname == GL_COMPILE_STATUS) {
         // HACK: ignore compile results for frag shaders, as some drivers may not compile them without explicit fragouts
         // (which we add at link-time)
@@ -93,12 +97,12 @@
 
 void glLinkProgram(GLuint program) {
     if(!current_context) return;
-    program_info_t* program_info = unordered_map_get(current_context->program_map, (void*)program);
+    program_info_t* program_info = unordered_map_get(current_context->program_map, GL_HANDLE_KEY(program));
     if(program_info == NULL || program_info->frag_shader == 0) {
         // Don't have any fragment shader to patch the locations in, fall through.
         goto fallthrough;
     }
-    shader_info_t *shader = unordered_map_get(current_context->shader_map, (void*)program_info->frag_shader);
+    shader_info_t *shader = unordered_map_get(current_context->shader_map, GL_HANDLE_KEY(program_info->frag_shader));
     if(shader == NULL) {
         printf("LTWShdrWp: failed to patch frag data location due to missing shader info\n");
         goto fallthrough;
@@ -158,14 +162,14 @@
         abort();
     }
     info_struct->shader_type = shaderType;
-    unordered_map_put(current_context->shader_map, (void*)phys_shader, info_struct);
+    unordered_map_put(current_context->shader_map, GL_HANDLE_KEY(phys_shader), info_struct);
     return phys_shader;
 }
 
 void glDeleteShader(GLuint shader) {
     if(!current_context) return;
     es3_functions.glDeleteShader(shader);
-    shader_info_t * old_shaderinfo = unordered_map_remove(current_context->shader_map, (void*)shader);
+    shader_info_t * old_shaderinfo = unordered_map_remove(current_context->shader_map, GL_HANDLE_KEY(shader));
     if(old_shaderinfo == NULL) return;
     if(old_shaderinfo->source != NULL) free((void*)old_shaderinfo->source);
     free(old_shaderinfo);
@@ -173,7 +177,7 @@
 
 void glShaderSource(GLuint shader, GLsizei count, const GLchar *const*string, const GLint *length) {
     if(!current_context) return;
-    shader_info_t* shader_info = unordered_map_get(current_context->shader_map, (void*)shader);
+    shader_info_t* shader_info = unordered_map_get(current_context->shader_map, GL_HANDLE_KEY(shader));
     if(shader_info == NULL) {
         printf("LTWShdrWp: shader_info missing for shader %u\n", shader);
         es3_functions.glShaderSource(shader, count, string, length);

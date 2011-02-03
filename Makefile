
C_SRC=src/main/c
WEB_SRC=src/report

INCLUDES=-I $(C_SRC) 
CPPFLAGS=-g -O0 -m64 -fPIC -pthread -Wreturn-type -W -Werror $(INCLUDES) -std=gnu++0x

STATIC_LIBS=-lssl 
APP_LIBS=-lboost_thread

.PHONY: all clean data show-data run-web-server

OBJ_DIR=obj
BIN_DIR=bin
WEB_DIR=web
WEB_PORT=5284

all: $(BIN_DIR)/seasocks $(BIN_DIR)/libseasocks.so

CPP_SRCS=$(shell find $(C_SRC) -name '*.cpp')	

OBJS=$(patsubst $(C_SRC)/%.cpp,$(OBJ_DIR)/%.o,$(CPP_SRCS))

-include $(OBJS:.o=.d)

obj/app/main.o : src/app/c/main.cpp
	@mkdir -p $(dir $@)
	$(CC)  $(CPPFLAGS) -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -c -o "$@" "$<" 

$(OBJS) : $(OBJ_DIR)/%.o : $(C_SRC)/%.cpp
	@mkdir -p $(dir $@)
	$(CC)  $(CPPFLAGS) -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -c -o "$@" "$<" 

$(BIN_DIR)/seasocks: $(OBJS) obj/app/main.o
	mkdir -p $(BIN_DIR)
	g++ $(CPPFLAGS) -o $@ $^ $(STATIC_LIBS) $(APP_LIBS)

$(BIN_DIR)/libseasocks.so: $(OBJS)
	mkdir -p $(BIN_DIR)
	g++ -shared $(CPPFLAGS) -o $@ $^ $(STATIC_LIBS)

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR) $(WEB_DIR) *.tar.gz

import socket

def main():
    # Create a socket object
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # Connect to the server
    server_address = ('localhost', 8888)
    print(f"Connecting to {server_address[0]} port {server_address[1]}")
    server.connect(server_address)
    state = 0
    # Off = 0
    # Standby = 1
    # Cruise = 2
    # Hold = 3
    
    try:
        while True:
            # User input for command
            cmd = server.recv(1024).decode("utf-8").strip()

            if cmd == "":
              break

            if cmd == "RESET":
              state = 0
              response = "23"
            elif cmd == "on":
              if state == 0:
                 state = 1
                 response = "24"
              else:
                 response = "25"
            elif cmd == "off":
              if state == 1 or state == 2 or state == 3:
                 state = 0
                 response = "26"
              else:
                 response = "27"
            elif cmd == "cancel":
              if state == 2 or state == 3:
                 state = 1
                 response = "28"
              else:
                 response = "29"
            elif cmd == "set":
              if state == 1:
                 state = 2
                 response = "30"
              else:
                 response = "30"
            elif cmd == "brake":
              if state == 2:
                 state = 3
                 response = "31"
              else:
                 response = "32"

            server.sendall((response + "\n").encode())
            
    finally:
        # Close the connection to the server
        print("Closing connection")
        server.close()

if __name__ == "__main__":
    main()

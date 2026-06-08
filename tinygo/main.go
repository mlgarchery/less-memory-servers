package main

import "syscall"

func main() {
	fd, err := syscall.Socket(syscall.AF_INET, syscall.SOCK_STREAM, 0)
	if err != nil {
		return
	}
	syscall.SetsockoptInt(fd, syscall.SOL_SOCKET, syscall.SO_REUSEADDR, 1)
	addr := syscall.SockaddrInet4{Port: 8085}
	if syscall.Bind(fd, &addr) != nil || syscall.Listen(fd, 128) != nil {
		syscall.Close(fd)
		return
	}
	buf := make([]byte, 1024)
	for {
		conn, _, err := syscall.Accept(fd)
		if err != nil {
			continue
		}
		n, _ := syscall.Read(conn, buf)
		if n >= 11 && string(buf[:11]) == "GET /hello " {
			syscall.Write(conn, []byte("HTTP/1.1 200 OK\r\nContent-Length: 11\r\n\r\nHello World"))
		} else if n > 0 {
			syscall.Write(conn, []byte("HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n"))
		}
		syscall.Close(conn)
	}
}

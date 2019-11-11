package main
import (
	"os"
	"io"
	"path/filepath"
	"fmt"
	"net/http"
)
func handle(w http.ResponseWriter, r *http.Request) {
	fmt.Println(r.Method + ": " + r.URL.Path)
    switch r.Method {
    case http.MethodGet:     
		fs := http.FileServer(http.Dir("/tmp/static/"))
        fs.ServeHTTP(w,r)
	case http.MethodPost:
		path := filepath.Join("/tmp/static", r.URL.Path)
		if info, err := os.Stat(path); err == nil && info.IsDir() {
			w.WriteHeader(http.StatusConflict)
			fmt.Fprintf(w, "NOK: Directory exists [" + path + "]")
			break
		 }
		os.MkdirAll(filepath.Dir(path), 0755)
		file,err := os.OpenFile(path, os.O_RDWR|os.O_CREATE, 0644)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			fmt.Fprintf(w, "NOK: Cannot open")
			break
		}
		if _, err := io.Copy(file, r.Body); err!=nil {
			w.WriteHeader(http.StatusInternalServerError)
			fmt.Fprintf(w, "NOK: Cannot write")
			break
		}
		fmt.Fprintf(w, "OK")
	case http.MethodDelete:
		path := filepath.Join("/tmp/static", r.URL.Path)
		err := os.RemoveAll(path)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			fmt.Fprintf(w, "NOK: Cannot delete [" + path + "]")
			break
		}
		fmt.Fprintf(w, "OK")
    default:
		w.WriteHeader(http.StatusBadRequest)
        fmt.Fprintf(w, "NOK: Only GET and POST methods are supported.")
    }
}
func main() {
	http.HandleFunc("/", handle)
	fmt.Println("Starting...")
	http.ListenAndServe(":3001", nil)
}
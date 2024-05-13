function loginForm() {
    return {
        username: '',
        password: '',
        login() {
            const data = { username: this.username, password: this.password };
            fetch('http://localhost:5500/login/user', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Login successful!');
                    localStorage.setItem('token', data.token);
                    localStorage.setItem('fullName', data.fullName);
                    localStorage.setItem('username', data.username);
                    localStorage.setItem('uId', data.uId);
                    window.location.href = '/Wproject/client/manage_books.html';
                } else {
                    alert(data.message);
                }
            })
            .catch((error) => {
                console.error('Error:', error);
            });
        }
    };
}

function registrationForm() {
    return {
        fullname: '',
        username: '',
        password: '',
        submitForm() {
            const data = {fullname: this.fullname, username: this.username, password: this.password };
            console.log(data);
            fetch('http://localhost:5500/register/newUser', {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
              })
            
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                // Handle the response data
                if (data.success) {
                    alert('Registration successful!');
                    window.location.href = '/Wproject/client/login.html';
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

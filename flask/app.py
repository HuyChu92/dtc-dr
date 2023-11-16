from flask import Flask, request

app = Flask(__name__)

@app.route('/sum', methods=['POST'])
def calculate_sum():
    data = request.get_json()
    result = sum(data.values())
    return {'sum': result}

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
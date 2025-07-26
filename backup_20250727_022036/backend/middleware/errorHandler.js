const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);
  
  // Default error
  let error = {
    success: false,
    error: 'Internal Server Error',
    message: 'Something went wrong'
  };
  
  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message).join(', ');
    error = {
      success: false,
      error: 'Validation Error',
      message
    };
    res.status(400).json(error);
  }
  // Mongoose duplicate key error
  else if (err.code === 11000) {
    const message = 'Duplicate field value entered';
    error = {
      success: false,
      error: 'Duplicate Field',
      message
    };
    res.status(400).json(error);
  }
  // JWT errors
  else if (err.name === 'JsonWebTokenError') {
    error = {
      success: false,
      error: 'Invalid Token',
      message: 'Please log in again'
    };
    res.status(401).json(error);
  }
  // JWT expired
  else if (err.name === 'TokenExpiredError') {
    error = {
      success: false,
      error: 'Token Expired',
      message: 'Please log in again'
    };
    res.status(401).json(error);
  }
  // Default to 500 server error
  else {
    res.status(500).json(error);
  }
};

module.exports = errorHandler;

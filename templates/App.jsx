import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { useAuth } from './context/AuthContext';
import LoginPage from './pages/LoginPage';
import SVGUploader from './components/SVGUploader';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import { Container, AppBar, Toolbar, Typography, Button } from '@mui/material';
import { Logout as LogoutIcon } from '@mui/icons-material';

const AppLayout = () => {
    const { isAuthenticated, logout } = useAuth();

    return (
        <>
            <AppBar position="static">
                <Toolbar>
                    <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
                        SVGViewer
                    </Typography>
                    {isAuthenticated && (
                        <Button 
                            color="inherit" 
                            startIcon={<LogoutIcon />}
                            onClick={logout}
                        >
                            Cerrar Sesión
                        </Button>
                    )}
                </Toolbar>
            </AppBar>
            <Container maxWidth="lg" sx={{ marginTop: 4 }}>
                <Routes>
                    <Route path="/login" element={<LoginPage />} />
                    <Route 
                        path="/" 
                        element={isAuthenticated ? <SVGUploader /> : <Navigate to="/login" />} 
                    />
                    <Route path="*" element={<Navigate to="/" />} />
                </Routes>
            </Container>
        </>
    );
};

function App() {
    return (
        <Router>
            <AuthProvider>
                <AppLayout />
                <ToastContainer position="bottom-right" />
            </AuthProvider>
        </Router>
    );
}

export default App;
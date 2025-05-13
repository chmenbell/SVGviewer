import React, { useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { toast } from 'react-toastify';
import { useAuth } from '../context/AuthContext';
import axios from 'axios';
import {
    Button, List, ListItem, ListItemText, Paper,
    Typography, Box, CircularProgress
} from '@mui/material';
import { CloudUpload as CloudUploadIcon, Autorenew as ConvertIcon } from '@mui/icons-material';

const SVGUploader = () => {
    const [files, setFiles] = useState([]);
    const [convertedSvgs, setConvertedSvgs] = useState([]);
    const [isConverting, setIsConverting] = useState(false);
    const { isAuthenticated, loading } = useAuth();

    const { getRootProps, getInputProps } = useDropzone({
        accept: {
            'application/vnd.visio': ['.vsdx'],
            'application/xml': ['.drawio', '.xml'],
        },
        maxFiles: 5,
        onDrop: acceptedFiles => {
            setFiles(acceptedFiles.map(file => Object.assign(file, {
                preview: URL.createObjectURL(file)
            })));
        }
    });

    const uploadFiles = async () => {
        if (files.length === 0) return;

        setIsConverting(true);
        const formData = new FormData();
        files.forEach(file => formData.append('files', file));

        try {
            const response = await axios.post('/api/svg-files/', formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
                withCredentials: true
            });
            toast.success('Archivos subidos correctamente');
            return response.data;
        } catch (error) {
            toast.error('Error al subir archivos');
            console.error(error);
        } finally {
            setIsConverting(false);
        }
    };

    const convertToSvg = async (fileId) => {
        try {
            setIsConverting(true);
            const response = await axios.post(
                `/api/svg-files/${fileId}/convert_to_svg/`,
                {},
                {
                    withCredentials: true
                }
            );
            toast.success('Conversión completada');
            setConvertedSvgs([...convertedSvgs, response.data.svg_url]);
        } catch (error) {
            toast.error('Error en la conversión');
            console.error(error);
        } finally {
            setIsConverting(false);
        }
    };

    if (loading) {
        return (
            <Box display="flex" justifyContent="center" alignItems="center" minHeight="200px">
                <CircularProgress />
            </Box>
        );
    }

    if (!isAuthenticated) {
        return (
            <Typography variant="h6" align="center" sx={{ marginTop: 4 }}>
                Por favor inicia sesión para acceder al conversor
            </Typography>
        );
    }

    return (
        <Box sx={{ maxWidth: 800, margin: '0 auto', padding: 3 }}>
            <Paper {...getRootProps()} sx={{ padding: 4, border: '2px dashed #ccc', textAlign: 'center', cursor: 'pointer', marginBottom: 3 }}>
                <input {...getInputProps()} />
                <CloudUploadIcon sx={{ fontSize: 50, color: 'action.active', marginBottom: 2 }} />
                <Typography variant="h6">Arrastra archivos .vsdx o .drawio aquí</Typography>
                <Typography variant="body1" sx={{ marginTop: 1 }}>o haz clic para seleccionar</Typography>
                <Typography variant="caption" color="text.secondary">(Máximo 5 archivos)</Typography>
            </Paper>

            <Button
                variant="contained"
                color="primary"
                onClick={uploadFiles}
                disabled={isConverting || files.length === 0}
                startIcon={isConverting ? <CircularProgress size={20} /> : null}
                fullWidth
                sx={{ marginBottom: 3 }}
            >
                {isConverting ? 'Subiendo...' : 'Subir archivos'}
            </Button>

            {files.length > 0 && (
                <Paper sx={{ padding: 3, marginBottom: 3 }}>
                    <Typography variant="h6" sx={{ marginBottom: 2 }}>Archivos subidos:</Typography>
                    <List>
                        {files.map((file, index) => (
                            <ListItem key={index} divider>
                                <ListItemText
                                    primary={file.name}
                                    secondary={`${(file.size / 1024).toFixed(2)} KB`}
                                />
                                <Button
                                    variant="outlined"
                                    color="secondary"
                                    onClick={() => convertToSvg(index)}
                                    disabled={isConverting}
                                    startIcon={<ConvertIcon />}
                                >
                                    Convertir
                                </Button>
                            </ListItem>
                        ))}
                    </List>
                </Paper>
            )}

            {convertedSvgs.length > 0 && (
                <Paper sx={{ padding: 3 }}>
                    <Typography variant="h6" sx={{ marginBottom: 2 }}>SVGs convertidos:</Typography>
                    {convertedSvgs.map((svgUrl, index) => (
                        <Box key={index} sx={{ marginBottom: 3 }}>
                            <img 
                                src={svgUrl}
                                alt={`Converted SVG ${index}`}
                                style={{ maxWidth: '100%', maxHeight: '300px', border: '1px solid #eee' }}
                            />
                            <Box sx={{ marginTop: 1 }}>
                                <Button
                                    variant="contained"
                                    color="primary"
                                    href={svgUrl}
                                    download
                                    sx={{ marginRight: 2 }}
                                >
                                    Descargar SVG
                                </Button>
                            </Box>
                        </Box>
                    ))}
                </Paper>
            )}
        </Box>
    );
};

export default SVGUploader;